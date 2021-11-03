import * as React from 'react';
import {FormControl, FormControlLabel, FormLabel, Radio, RadioGroup} from "@material-ui/core";

export default function CustomRadios(props) {
    return (
        <FormControl component="fieldset" className={props.class}>
            <FormLabel component="legend">{props.label}</FormLabel>
            <RadioGroup row>
                {getRadios()}
            </RadioGroup>
        </FormControl>
    );

    function getRadios() {
        return props.options.map((option, index) => {
            return <FormControlLabel key={index} value={option} control={<Radio color="primary" onClick={() => props.set(option)} />} label={option} />
        })
    }
}