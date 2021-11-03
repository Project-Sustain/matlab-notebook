import * as React from 'react';
import {makeStyles, TextField} from "@material-ui/core";
import { Autocomplete } from '@material-ui/lab';
import {countyMap} from "../utils/StateCountyMapping";

export default function CustomAutocomplete(props) {

    function handleChange(value) {
        if(props.type === "state") {
            props.dataManagement.setSelectedState(value);
            props.dataManagement.setCounties(countyMap[`${value}`]);
        }
        else if(props.type === "county") {
            props.dataManagement.setSelectedCounty(value);
        }
        else if(props.type === "dataset") {
            // FIXME update selected dataset, once we have that available
        }
    }

    return (
        <Autocomplete
            className={props.class}
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
