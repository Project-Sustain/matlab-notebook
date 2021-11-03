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
});

export default function Main() {
    const classes = useStyles();
    const timePeriods = ["year", "month", "day", "hour"];
    const timeSteps = ["0", "3", "6"];
    const field = "total_precipitation_kg_per_squared_meter"; //FIXME hard-coded for now

    const [selectedState, setSelectedState] = useState("Colorado");
    const [counties, setCounties] = useState([]);
    const [selectedCounty, setSelectedCounty] = useState("Larimer");
    const [timePeriod, setTimePeriod] = useState(timePeriods[0]);
    const [timeStep, setTimeStep] = useState(timeSteps[0]);
    const [collection, setCollection] = useState("noaa-nam"); //FIXME hard-coded for now

    const [gisJoin, setGisJoin] = useState("");
    const [open, setOpen] = useState(false);

    return (
        <Grid container direction="row" justifyContent="center" alignItems="center">
            <Paper className={classes.root}>
                <Grid container direction="column" justifyContent="center" alignItems="center">
                    <CustomAutocomplete
                        label="Choose a State"
                        options={stateArray}
                        state={{ setSelectedState, setCounties, setSelectedCounty, selectedState }}
                        disabled={false}
                        type="state"
                    />
                    <CustomAutocomplete
                        label="Choose a County"
                        options={counties}
                        state={{ setSelectedCounty, selectedCounty }}
                        disabled={selectedState === ""}
                        type="county"
                    />
                    <CustomAutocomplete
                        label="Choose a Dataset"
                        options={[]} //FIXME hard-coded for now
                        state={{ setCollection, collection }}
                        disabled={true} //FIXME hard-coded for now
                        type="dataset"
                    />
                    <CustomRadios options={timePeriods} set={setTimePeriod} access={timePeriod} label="Time Period" />
                    <CustomRadios options={timeSteps} set={setTimeStep} access={timeStep} label="Time Step" />
                    <Button variant="outlined" onClick={handleSubmit}>Submit</Button>
                </Grid>
            </Paper>
                <Response state={{ open, setOpen, gisJoin, collection, field, timePeriod, timeStep }} />
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
        setOpen(true)
        findGISJoin();
    }
}