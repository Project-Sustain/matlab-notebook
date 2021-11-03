import React, {useState} from 'react';
import {Grid, makeStyles, Paper} from "@material-ui/core";
import CustomAutocomplete from "./CustomAutocomplete";
import {stateArray} from "../utils/StateCountyMapping";

const useStyles = makeStyles({
    root: {
        width: "50vw",
        margin: "20px",
        padding: "20px",
    },
});

export default function Main() {
    const classes = useStyles();
    const [selectedState, setSelectedState] = useState("");
    const [counties, setCounties] = useState([]);
    const [selectedCounty, setSelectedCounty] = useState([]);
    console.log({selectedCounty})

    const dataManagement = {setSelectedState, setCounties, setSelectedCounty}

    return (
        <Grid container direction="row" justifyContent="center" alignItems="center">
            <Paper className={classes.root}>
                <Grid container direction="column" justifyContent="center" alignItems="center">
                    <CustomAutocomplete label="Choose a State" options={stateArray} dataManagement={dataManagement} disabled={false} type="state" />
                    <CustomAutocomplete label="Choose a County" options={counties} dataManagement={dataManagement} disabled={selectedState === ""} type="county" />
                </Grid>
            </Paper>
        </Grid>
    )
}