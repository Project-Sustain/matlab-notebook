import * as React from 'react';
import {makeStyles, TextField} from "@material-ui/core";
import { Autocomplete } from '@material-ui/lab';
import {countyMap} from "../utils/StateCountyMapping";

const useStyles = makeStyles({
    root: {
        width: "60%",
        margin: "10px"
    },
});

export default function CustomAutocomplete(props) {
    const classes = useStyles();

    function handleChange(value) {
        if(props.type === "state") {
            props.dataManagement.setSelectedState(value);
            props.dataManagement.setCounties(countyMap[`${value}`]);
        }
        else if(props.type === "county") {
            props.dataManagement.setSelectedCounty(value);
        }
    }

    return (
        <Autocomplete
            className={classes.root}
            disabled={props.disabled}
            autoHighlight
            options={props.options}
            onChange={(event, value) => {
                if (value) {
                    handleChange(value);
                }
            }}
            renderInput={(params) => <TextField variant="outlined" {...params} label={props.label} />}
        />
    );
}
