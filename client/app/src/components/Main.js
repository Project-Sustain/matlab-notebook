import React, {useState} from 'react';
import {Button, Grid, makeStyles, Paper} from "@material-ui/core";
import CustomAutocomplete from "./CustomAutocomplete";
import {stateArray} from "../utils/StateCountyMapping";
import CustomRadios from "./CustomRadios";
import {countyGIS} from "../utils/gis_county";
import Response from "./Response";

const useStyles = makeStyles({
    root: {
        width: "50vw",
        margin: "20px",
        padding: "20px",
    },
    autocomplete: {
        width: "60%",
        margin: "10px"
    },
    radios: {
        margin: "10px",
    }
});

export default function Main() {
    const classes = useStyles();
    const [selectedState, setSelectedState] = useState("");
    const [counties, setCounties] = useState([]);
    const [selectedCounty, setSelectedCounty] = useState([]);

    const timePeriods = ["year", "month", "day", "hour"];
    const [timePeriod, setTimePeriod] = useState(timePeriods[0]);

    const timeSteps = ["0", "3", "6"];
    const [timeStep, setTimeStep] = useState(timeSteps[0]);

    const [collection, setCollection] = useState("noaa-nam"); //FIXME Remove hard-coding once dataset are incorporated

    const dataManagement = {setSelectedState, setCounties, setSelectedCounty, setCollection}

    const [gisJoin, setGisJoin] = useState("");
    const [response, setResponse] = useState(false);

    const field = "total_precipitation_kg_per_squared_meter"

    const data = {gisJoin, field, collection, timePeriod, timeStep, response, setResponse}

    return (
        <Grid container direction="row" justifyContent="center" alignItems="center">
            <Paper className={classes.root}>
                <Grid container direction="column" justifyContent="center" alignItems="center">
                    <CustomAutocomplete label="Choose a State" options={stateArray} dataManagement={dataManagement} disabled={false} type="state" class={classes.autocomplete} />
                    <CustomAutocomplete label="Choose a County" options={counties} dataManagement={dataManagement} disabled={selectedState === ""} type="county" class={classes.autocomplete} />
                    <CustomAutocomplete label="Choose a Dataset" options={[]} dataManagement={dataManagement} disabled={true} type="dataset" class={classes.autocomplete} />
                    <CustomRadios class={classes.radios} options={timePeriods} set={setTimePeriod} access={timePeriod} label="Time Period" />
                    <CustomRadios class={classes.radios} options={timeSteps} set={setTimeStep} access={timeStep} label="Time Step" />
                    <Button variant="outlined" onClick={handleSubmit}>Submit</Button>
                </Grid>
            </Paper>
                <Response data={data} />
        </Grid>
    )

    function findGISJoin() {
        const searchString = `${selectedCounty} County, ${selectedState}`;
        countyGIS.forEach((county) => {
            if(county.name === searchString) {
                setGisJoin(county.GISJOIN);
            }
        });
    }

    function handleSubmit() {
        setResponse(true)
        findGISJoin();
    }
}