import React, {useState} from 'react';
import {TextField, Grid, makeStyles, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow} from "@material-ui/core";
import { Autocomplete } from '@material-ui/lab';
import CustomAutocomplete from "./CustomAutocomplete";
import {stateArray, countyMap} from "../utils/StateCountyMapping";
import {sendServerRequestWithBody} from "../utils/requests"
import CustomRadios from "./CustomRadios";
import Response from "./Response";

var gisJoinJson = require('../resources/gis_joins.json');

const useStyles = makeStyles({
    root: {
        width: "60vw",
        margin: "20px",
        padding: "20px",
    },
    autocomplete: {
        width: "45%",
        margin: "10px"
    },
    tableHeader: {
        fontWeight: "bold"
    }
});

export default function Main() {
    const classes = useStyles();

    const timePeriods = ["year", "month", "day", "hour"];
    const timeSteps = ["0", "3", "6"];
    const [selectedState, setSelectedState] = useState(null);
    const [selectedCounty, setSelectedCounty] = useState(null);
    const [timePeriod, setTimePeriod] = useState(timePeriods[0]);
    const [timeStep, setTimeStep] = useState(timeSteps[0]);
    const [selectedField, setSelectedField] = useState(null); //FIXME hard-coded for now
    const [selectedCollection, setSelectedCollection] = useState(null);
    const [gisJoin, setGisJoin] = useState(null);
    const [open, setOpen] = useState(false);

    const supportedCollectionsMetadata = {
        "NOAA NAM": {
            name: "NOAA NAM",
            collection: "noaa_nam",
            supportedFields: {
                "Temperature at Surface": {
                    name: "Temperature at Surface",
                    field: "TEMPERATURE_AT_SURFACE_KELVIN",
                    unit: "Kelvin",
                    type: "Floating-point",
                    isAccumulationBased: "true"
                }
            }
        }
    };

    function handleSelectStateChange(value) {
        console.log("Selected State changed to", value);
        if (value in gisJoinJson["states"]) {
            setSelectedState(gisJoinJson["states"][value]);
        }
    }

    function handleSelectCountyChange(value) {
        console.log("Selected County changed to", value);
        if (selectedState) {
            if (value in selectedState["counties"]) {
                setSelectedCounty(selectedState["counties"][value]);
            }
        }
    }

    function handleSelectCollectionChange(value) {
        console.log("Selected Collection by name", value);
        if (value in supportedCollectionsMetadata) {
            setSelectedCollection(supportedCollectionsMetadata[value]);
        }
    }

    function handleSelectFieldChange(value) {
        console.log("Selected Collection by name", value);
        if (selectedCollection) {
            if (value in selectedCollection["supportedFields"]) {
                setSelectedField(selectedCollection["supportedFields"][value]);
            }
        }
    }

    function getStateInput() {
        return (<Grid item xs={6} md={6}>
                    <Autocomplete
                        className={classes.autocomplete}
                        autoHighlight
                        defaultValue={Object.keys(gisJoinJson["states"])[0]}
                        options={Object.keys(gisJoinJson["states"])}
                        value={selectedState ? selectedState.name : ''}
                        onChange={(event, value) => {
                            if (value) {
                                handleSelectStateChange(value);
                            }
                        }}
                        renderInput={(params) => <TextField variant="outlined" required {...params} label={"State"} />}
                    />
                </Grid>);
    }

    function getCountyInput() {
        if (selectedState) {
            return (
                <Grid item xs={6} md={6}>
                    <Autocomplete
                        className={classes.autocomplete}
                        autoHighlight
                        options={selectedState ? Object.keys(selectedState["counties"]) : []}
                        value={selectedCounty ? selectedCounty.name : ''}
                        onChange={(event, value) => {
                            if (value) {
                                handleSelectCountyChange(value);
                            }
                        }}
                        renderInput={(params) => <TextField variant="outlined" {...params} label={"County"} />}
                    />
                </Grid>
            );
        }
        return null;
    }

    function getCollectionInput() {
        if (selectedState) {
            return (
                <Grid item xs={6} md={6}>
                    <Autocomplete
                        className={classes.autocomplete}
                        autoHighlight
                        options={Object.keys(supportedCollectionsMetadata)}
                        defaultValue={Object.keys(supportedCollectionsMetadata)[0]}
                        value={selectedCollection ? selectedCollection.name : ''}
                        onChange={(event, value) => {
                            if (value) {
                                handleSelectCollectionChange(value);
                            }
                        }}
                        renderInput={(params) => <TextField variant="outlined" required {...params} label={"Collections"} />}
                    />
                </Grid>
            );
        }
        return null;
    }

    function getCollectionFieldInput() {
        if (selectedCollection) {
            return (
                <Grid item xs={6} md={6}>
                    <Autocomplete
                        className={classes.autocomplete}
                        autoHighlight
                        options={Object.keys(selectedCollection["supportedFields"])}
                        defaultValue={Object.keys(selectedCollection["supportedFields"])[0]}
                        value={selectedField ? selectedField.name : ''}
                        onChange={(event, value) => {
                            if (value) {
                                handleSelectFieldChange(value);
                            }
                        }}
                        renderInput={(params) => <TextField variant="outlined" required {...params} label={"Field"} />}
                    />
                </Grid>
            );
        }
        return null;
    }

    function getCollectionFieldsInfo() {
        if (selectedCollection) {

            let rows = [];
            let fields = selectedCollection["supportedFields"];
            for (let key in fields) {
                console.log(key);
                let value = fields[key];
                rows.push(value);
            }

            console.log(rows);

            return (
                <Grid item xs={10} md={10}>
                    <TableContainer>
                        <Table sx={{ minWidth: 650 }} aria-label="simple table">
                            <TableHead>
                                <TableRow>
                                    <TableCell className={classes.tableHeader}>Field</TableCell>
                                    <TableCell className={classes.tableHeader} align="right">Unit</TableCell>
                                    <TableCell className={classes.tableHeader} align="right">Data Type</TableCell>
                                    <TableCell className={classes.tableHeader} align="right">Accumulation-based</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {rows.map((row) => 
                                    <TableRow
                                        key={row.name}
                                        sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                                    >
                                        <TableCell component="th" scope="row">{row.name}</TableCell>
                                        <TableCell align="right">{row.unit}</TableCell>
                                        <TableCell align="right">{row.type}</TableCell>
                                        <TableCell align="right">{row.isAccumulationBased}</TableCell>
                                    </TableRow>
                                )}
                            </TableBody>
                        </Table>
                    </TableContainer>
                </Grid>
            );
        }
        return null;
    }

    function findGisJoin() {
        if (selectedState) {
            if (selectedCounty) {
                setGisJoin(selectedCounty["GISJOIN"]);
            } else {
                setGisJoin(selectedState["GISJOIN"]);
            }
            console.log("Updated GISJOIN to", gisJoin)
        }
        console.error("Selected State cannot be empty!");
    }

    return (
        <Paper elevation={3} className={classes.root}>
            <Grid container spacing={2} direction="row">
                {getStateInput()}
                {getCountyInput()}
                {getCollectionInput()}
                {getCollectionFieldInput()}
                {getCollectionFieldsInfo()}
            </Grid>
        </Paper>
    );


    function handleSubmit() {
        findGisJoin();
        //setOpen(true);
        /*
        let requestBody = {
            "collection": collection,
            "field": field,
            "gisJoin": gisJoin,
            "period": timePeriod,
            "timestep": timeStep
        };

        if (gisJoin !== "") {
            sendServerRequestWithBody("localhost", 8081, "eva", requestBody)
            .then(response => {
                console.log(response);
            });
        } else {
            console.log("gisJoin is empty");
        }
        */
    }
    
}