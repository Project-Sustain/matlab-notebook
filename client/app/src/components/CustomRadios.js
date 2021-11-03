import * as React from 'react';
import {FormControl, FormControlLabel, Grid, Radio, RadioGroup, Typography} from "@material-ui/core";

export default function CustomRadios(props) {
    return (
        <>
            <Grid container direction="row" justifyContent="center" alignItems="center">
                <Grid item>
                    <Typography component="legend" style={{color: "#818181"}}>
                        {props.label}:
                    </Typography>
                </Grid>
                <Grid item>
                    <FormControl component="fieldset" className={props.class}>
                        <RadioGroup row>
                            {getRadios()}
                        </RadioGroup>
                    </FormControl>
                </Grid>
            </Grid>
        </>
    );

    function getRadios() {
        return props.options.map((option, index) => {
            return <FormControlLabel key={index} value={option} control={<Radio color="primary" onClick={() => props.set(option)} />} label={option} />
        })
    }
}