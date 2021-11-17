import * as React from 'react';
import {FormControl, FormControlLabel, Grid, makeStyles, Radio, RadioGroup, Typography} from "@material-ui/core";

const useStyles = makeStyles({
    root: {
        margin: "10px",
    }
});

export default function CustomRadios(props) {
    const classes = useStyles();
    return (
        <>
            <Grid container direction="row" justifyContent="center" alignItems="center">
                <Grid item>
                    <Typography component="legend" style={{color: "#818181"}}>
                        {props.label}:
                    </Typography>
                </Grid>
                <Grid item>
                    <FormControl component="fieldset" className={classes.root}>
                        <RadioGroup row>
                            {getRadios()}
                        </RadioGroup>
                    </FormControl>
                </Grid>
            </Grid>
        </>
    );

    function getRadios() {
    }
}