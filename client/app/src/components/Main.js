import React, {useState} from 'react';
import {
    Button, TextField, Grid, makeStyles, Paper, Table, TableBody, TableCell, TableContainer,
    FormControl, FormControlLabel, Radio, RadioGroup, FormLabel, TableHead, TableRow, Typography
} from "@material-ui/core";
import { Autocomplete } from '@material-ui/lab';
import {sendServerRequestWithBody} from "../api/requests";
import Results from './Results';

const gisJoinJson = require('../resources/gis_joins.json');
const supportedCollectionsMetadata = require('../resources/collections_metadata.json');
const exampleResponse = require('../resources/example_response.json');

const useStyles = makeStyles({
    wipBanner: {
        width: "auto",
        margin: "20px",
        padding: "20px",
        backgroundColor: "#f7dd86"
    },
    completedBanner: {
        width: "auto",
        margin: "20px",
        padding: "20px",
        backgroundColor: "#77b86e",
        color: "white"
    },
    root: {
        width: "auto",
        margin: "20px",
        padding: "20px",
    },
    autocomplete: {
        width: "50%",
        margin: "auto"
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
    const [currentRequest, setCurrentRequest] = useState(null);
    const [currentResponse, setCurrentResponse] = useState(null);
    const [submittedRequest, setSubmittedRequest] = useState(false);

    function findGisJoin() {
        if (selectedState) {
            if (selectedCounty) {
                console.log("County GISJOIN:", selectedCounty["GISJOIN"]);
                return selectedCounty["GISJOIN"];
            } else {
                console.log("State GISJOIN:", selectedState["GISJOIN"]);
                return selectedState["GISJOIN"];
            }
        } else {
            console.error("Selected State cannot be empty!");
            return null;
        }
    }

    function handleSelectStateChange(value) {
        if (value in gisJoinJson["states"]) {
            console.log("Selected State changed to", gisJoinJson["states"][value]);
            setSelectedState(gisJoinJson["states"][value]);
            setSelectedCounty(null);
        }
    }

    function handleSelectCountyChange(value) {
        if (selectedState) {
            if (value in selectedState["counties"]) {
                console.log("Selected County changed to", selectedState["counties"][value]);
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

    function handleSubmit() {
        let gisJoin = findGisJoin();

        if (gisJoin !== "") {
            let requestBody = {
                "collection": selectedCollection["collection"],
                "field": selectedField["field"],
                "gisJoin": gisJoin,
                "period": selectedReturnPeriod,
                "timestep": selectedTimestep
            };

            setSubmittedRequest(true);
            setCurrentRequest(requestBody);

            sendServerRequestWithBody("lattice-106.cs.colostate.edu", 31415, "eva", requestBody)
                .then(response => {
                    console.log(`Received response: code: ${response.statusCode}`);
                    console.log(`Received response: statusText: ${response.statusText}`);
                    console.log(`Received response: body:`, response.body);
                    setCurrentResponse(response.body);
                    setSubmittedRequest(false);
                });

        } else {
            console.log("Cannot submit request; gisJoin is empty!");
        }
    }

    function handleReset() {
        console.log("Resetting all fields...");
        setSelectedCollection(null);
        setSelectedField(null);
        setSelectedState(null);
        setSelectedCounty(null);
        setSelectedReturnPeriod(null);
        setSelectedTimestep(0);
        setCurrentRequest(null);
        setCurrentResponse(null);
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
                    disabled={!selectedState}
                    renderInput={(params) => <TextField variant="outlined" {...params} label={"County"} />}
                />
            </Grid>
        );
    }

    function getCollectionInput() {
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

    function getCollectionFieldInput() {
        return (
            <Grid item xs={6} md={6}>
                <Autocomplete
                    className={classes.autocomplete}
                    autoHighlight
                    options={selectedCollection ? Object.keys(selectedCollection["supportedFields"]) : []}
                    defaultValue={selectedCollection ? Object.keys(selectedCollection["supportedFields"])[0] : ''}
                    value={selectedField ? selectedField.name : ''}
                    onChange={(event, value) => {
                        if (value) {
                            handleSelectFieldChange(value);
                        }
                    }}
                    disabled={!selectedCollection}
                    renderInput={(params) => <TextField variant="outlined" required {...params} label={"Field"} />}
                />
            </Grid>
        );
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
                <Grid item xs={8} md={8}>
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

    function getCollectionDescription() {
        if (selectedCollection) {
            return (
                <Grid item xs={4} md={4}>
                    <Typography variant="h5">Dataset Description</Typography>
                    <Typography align="left">
                        From <a href={selectedCollection["descriptionSource"]}>{selectedCollection["longName"]}</a>:
                        <em>{selectedCollection["description"]}</em>
                    </Typography>
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
                    <Grid item xs={4} md={6}>
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

    function getSubmitAndResetButtons() {
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
                <Button variant="outlined" onClick={handleReset}>Reset</Button>
            </Grid>
        );
    }

    function getWorkInProgressBanner() {
        return (
            <Paper elevation={3} className={classes.wipBanner}>
                Site/Service currently in-progress. <em>Coming soon</em>: Support for more datasets, user-defined models
            </Paper>
        );
    }

    function getAwaitingResponseBanner() {
        if (submittedRequest) {
            return (
                <Paper elevation={3} className={classes.wipBanner}>
                    Submitted request. Waiting for SUSTAIN to determine block extrema, run ProNEVA, and return results; This may take a few minutes.
                </Paper>
            );
        } else {
            return null;
        }
    }

    function getFinishedResponseBanner() {
        if (currentResponse) {
            return (
                <Paper elevation={3} className={classes.completedBanner}>
                    Received response. See the plotted results below.
                </Paper>
            );
        } else {
            return null;
        }
    }

    function getResults() {
        if (currentResponse && selectedField && selectedReturnPeriod) {
            return <Results unit={selectedField["unit"]} returnPeriod={selectedReturnPeriod} response={currentResponse}/>
        } else {
            return null;
        }
    }

    return (
        <div>
            {getWorkInProgressBanner()}
            <Paper elevation={3} className={classes.root}>
                <Grid container spacing={2} direction="row" justifyContent="center" alignItems="center">
                    {getStateInput()}
                    {getCountyInput()}
                    {getCollectionInput()}
                    {getCollectionFieldInput()}
                    {getTimestepRadios()}
                    {getReturnPeriodRadios()}
                    {getSubmitAndResetButtons()}
                    {getCollectionFieldsInfo()}
                    {getCollectionDescription()}
                </Grid>
            </Paper>
            {getAwaitingResponseBanner()}
            {getFinishedResponseBanner()}
            {getResults()}
        </div>
    );
}