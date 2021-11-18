import React, {useState} from 'react';
import {Button, TextField, Grid, makeStyles, Paper, Table, TableBody, TableCell, TableContainer,
    FormControl, FormControlLabel, Radio, RadioGroup, FormLabel, TableHead, TableRow} from "@material-ui/core";
import { Autocomplete } from '@material-ui/lab';
import {sendServerRequestWithBody} from "../api/requests";
import Results from './Results';

var gisJoinJson = require('../resources/gis_joins.json');
var supportedCollectionsMetadata = require('../resources/collections_metadata.json');

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
    },
    scrollable: {
        maxHeight: 285,
        overflow: "auto"
    }
});

export default function Main() {
    const classes = useStyles();

    const [selectedState, setSelectedState] = useState(null);
    const [selectedCounty, setSelectedCounty] = useState(null);
    const [selectedReturnPeriod, setSelectedReturnPeriod] = useState(null);
    const [selectedTimestep, setSelectedTimestep] = useState(0);
    const [selectedField, setSelectedField] = useState(null);
    const [selectedCollection, setSelectedCollection] = useState(null);
    const [gisJoin, setGisJoin] = useState(null);

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
                let fieldObj = selectedCollection["supportedFields"][value];
                if (fieldObj["accumulationOrInstant"] === "Instant") {
                    setSelectedTimestep(0);
                }
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
                let value = fields[key];
                rows.push(value);
            }

            return (
                <Grid item xs={10} md={10}>
                    <div className={classes.scrollable}>                 
                    <TableContainer>
                        <Table aria-label="a dense table">
                            <TableHead>
                                <TableRow>
                                    <TableCell className={classes.tableHeader}>Field</TableCell>
                                    <TableCell className={classes.tableHeader} align="right">Unit</TableCell>
                                    <TableCell className={classes.tableHeader} align="right">Data Type</TableCell>
                                    <TableCell className={classes.tableHeader} align="right">Instant/Accumulation</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {rows.map((row) => 
                                    <TableRow
                                        key={"key_"+row.name}
                                        sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                                    >
                                        <TableCell component="th" scope="row">{row.name}</TableCell>
                                        <TableCell align="right">{row.unit}</TableCell>
                                        <TableCell align="right">{row.type}</TableCell>
                                        <TableCell align="right">{row.accumulationOrInstant}</TableCell>
                                    </TableRow>
                                )}
                            </TableBody>
                        </Table>
                    </TableContainer>
                    </div>
                </Grid>
            );
        }
        return null;
    }

    function getTimestepRadios() {
        if (selectedCollection && selectedCollection.name === "NOAA NAM") {
            if (selectedField && selectedField.accumulationOrInstant === "Accumulation") {
                let timesteps = [3,6];
                return (
                    <Grid item xs={10} md={10}>
                        <FormControl component="fieldset">
                            <FormLabel component="legend">Timestep (Accumulation Period)</FormLabel>
                            <RadioGroup row aria-label="timestep" name="row-radio-buttons-group">
                                {timesteps.map((timestep) => 
                                    <FormControlLabel
                                        value={timestep}
                                        label={`${timestep} hours`}
                                        key={"timestep_formcontrol_key_"+timestep}
                                        control={<Radio 
                                            color="primary"
                                            key={"timestep_radio_key_"+timestep}
                                            checked={selectedTimestep === timestep}
                                            onClick={() => setSelectedTimestep(timestep)}
                                        />}
                                    />
                                )}
                            </RadioGroup>
                        </FormControl>
                    </Grid>
                );
            }
        }
        return null;
    }

    function getReturnPeriodRadios() {
        if (selectedCollection && selectedCollection.name === "NOAA NAM") {
            if (selectedField) {
                let returnPeriods = ["year", "month", "day", "hour"];
                return (
                    <Grid item xs={10} md={10}>
                        <FormControl component="fieldset">
                            <FormLabel component="legend">Return Period</FormLabel>
                            <RadioGroup row aria-label="returnperiods" name="row-radio-buttons-group">
                                {returnPeriods.map((returnPeriod) => 
                                    <FormControlLabel
                                        value={returnPeriod}
                                        label={returnPeriod}
                                        key={"returnperiod_formcontrol_key_"+returnPeriod}
                                        control={<Radio 
                                            color="primary"
                                            key={"returnperiod_radio_key_"+returnPeriod}
                                            checked={selectedReturnPeriod === returnPeriod}
                                            onClick={() => setSelectedReturnPeriod(returnPeriod)}
                                        />}
                                    />
                                )}
                            </RadioGroup>
                        </FormControl>
                    </Grid>
                );
            }
        }
        return null;
    }

    function getSubmitButton() {
        let enabled = false;
        if (selectedState && selectedCollection && selectedField && selectedReturnPeriod) {
            if (selectedField["accumulationOrInstant"] === "Accumulation") {
                enabled = selectedTimestep === 6 || selectedTimestep === 3;
            } else {
                enabled = selectedTimestep === 0;
            }
        }

        return (
            <Grid item xs={10} md={10}>
                <Button disabled={!enabled} variant="outlined" onClick={handleSubmit}>Submit</Button>
            </Grid>
        );
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

    return (
        <div>
            <Paper elevation={3} className={classes.root}>
                <Grid container spacing={2} direction="row">
                    {getStateInput()}
                    {getCountyInput()}
                    {getCollectionInput()}
                    {getCollectionFieldInput()}
                    {getTimestepRadios()}
                    {getReturnPeriodRadios()}
                    {getSubmitButton()}
                    {getCollectionFieldsInfo()}
                </Grid>
                
            </Paper>
            <Results></Results>
        </div>
    );
}