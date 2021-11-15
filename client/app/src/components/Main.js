import React, {useState} from 'react';
import {Button, Grid, makeStyles, Paper} from "@material-ui/core";
import CustomAutocomplete from "./CustomAutocomplete";
import {stateArray, countyMap} from "../utils/StateCountyMapping";
import CustomRadios from "./CustomRadios";
import {countyGIS} from "../utils/gis_county";
import Response from "./Response";

const useStyles = makeStyles({
    root: {
        width: "60vw",
        margin: "20px",
        padding: "20px",
    },
});

export default function Main() {
    const classes = useStyles();
    const timePeriods = ["year", "month", "day", "hour"];
    const timeSteps = ["0", "3", "6"];

    const [selectedState, setSelectedState] = useState("Colorado");
    const [selectedCounty, setSelectedCounty] = useState(countyMap["Colorado"].counties[0]);
    const [timePeriod, setTimePeriod] = useState(timePeriods[0]);
    const [timeStep, setTimeStep] = useState(timeSteps[0]);
    const [field, setField] = useState("TEMPERATURE_AT_SURFACE_KELVIN"); //FIXME hard-coded for now
    const [collection, setCollection] = useState("noaa_nam"); //FIXME hard-coded for now
    const [gisJoin, setGisJoin] = useState("");
    const [open, setOpen] = useState(false);

    return (
        <Grid container direction="row" justifyContent="center" alignItems="center">
            <Paper elevation={3} className={classes.root}>
                <Grid container direction="row" justifyContent="center" alignItems="center">
                    <CustomAutocomplete
                        label="Choose a State"
                        options={stateArray}
                        state={{ setSelectedState, setSelectedCounty, selectedState, setGisJoin }}
                        disabled={false}
                        type="state"
                    />
                    <CustomAutocomplete
                        label="Choose a Dataset"
                        options={[]} //FIXME hard-coded for now
                        state={{ setCollection, collection }}
                        disabled={true} //FIXME hard-coded for now
                        type="collection"
                    />
                </Grid>
                <Grid container direction="row" justifyContent="center" alignItems="center">
                    <CustomAutocomplete
                        label="Choose a County"
                        options={countyMap[`${selectedState}`].counties}
                        state={{ setSelectedCounty, selectedCounty, setGisJoin }}
                        disabled={selectedState === ""}
                        type="county"
                    />
                    <CustomAutocomplete
                        label="Choose a Field"
                        options={[]} //FIXME hard-coded for now
                        state={{ setField, field }}
                        disabled={true} //FIXME hard-coded for now
                        type="field"
                    />
                </Grid>
                <Grid container direction="row" justifyContent="center" alignItems="center">
                    <CustomRadios options={timePeriods} set={setTimePeriod} access={timePeriod} label="Time Period" />
                    <CustomRadios options={timeSteps} set={setTimeStep} access={timeStep} label="Time Step" />
                    <Button variant="outlined" onClick={handleSubmit}>Submit</Button>
                </Grid>
            </Paper>
            <Response state={{ open, setOpen, gisJoin, collection, field, timePeriod, timeStep }} />
        </Grid>
    )

    function findGISJoin() {
        const searchString = `${selectedCounty}, ${selectedState}`;
        countyGIS.forEach((county) => {
            if(county.name === searchString) {
                setGisJoin(county.GISJOIN);
            }
        });
    }

    function handleSubmit() {
        findGISJoin();
        setOpen(true);
        let requestBody = {
            "collection": collection,
            "field": field,
            "gisJoin": gisJoin,
            "period": timePeriod,
            "timestep": timeStep
        };
        var xhr = new XMLHttpRequest();
        var url = "http://localhost:8081/eva";
        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Access-Control-Allow-Origin", "*");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var json = JSON.parse(xhr.responseText);
                console.log(json);
            }
        };
        var data = JSON.stringify(requestBody);
        xhr.send(data);
    }

    function sendServerRequestWithBody(requestBody, serverPort=8081) {
        const restfulAPI = `http://lattice-100:${serverPort}/eva`;
        const requestOptions = {
            method: "POST",
            headers: {
                'Content-Type': 'application/json'
            },
            mode: 'no-cors',
            body: JSON.stringify(requestBody)
        };
        return processRestfulAPI(restfulAPI, requestOptions);
    }

    async function processRestfulAPI(restfulAPI, requestOptions) {
        try {
            console.log(requestOptions)
            let response = await fetch(restfulAPI, requestOptions);
            console.log(response);
            return {
                statusCode: response.status,
                statusText: response.statusText,
                body: await response.json()
            };
        } catch(err) {
            console.error(err);
            return { statusCode: 0, statusText: 'Client failure', body: null };
        }
    }
}