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
            props.state.setSelectedState(value);
            props.state.setCounties(countyMap[`${value}`]);
            props.state.setSelectedCounty(countyMap[`${value}`][0]);
        }
        else if(props.type === "county") {
            props.state.setSelectedCounty(value);
        }
        else if(props.type === "dataset") {
            // FIXME update selected dataset, once we have that available
        }
    }

    function getValue() {
        if(props.type === "state") {
            return props.state.selectedState;
        }
        else if(props.type === "county") {
            return props.state.selectedCounty;
        }
        else if(props.type === "dataset") {
            return props.state.collection;
        }
    }

    return (
        <Autocomplete
            className={classes.root}
            disabled={props.disabled}
            autoHighlight
            options={props.options}
            value={getValue()}
            onChange={(event, value) => {
                if (value) {
                    handleChange(value);
                }
            }}
            renderInput={(params) => <TextField variant="outlined" {...params} label={props.label} />}
        />
    );
}
