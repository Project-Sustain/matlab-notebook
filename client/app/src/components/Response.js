import React from 'react';
import {Button, Grid, makeStyles, Paper, Typography} from "@material-ui/core";

const useStyles = makeStyles({
    root: {
        width: "50vw",
        margin: "20px",
        padding: "20px",
    },
});

export default function Response(props) {
    const classes = useStyles();
    if(props.data.response) {
        let returnObj = {
            collection: props.data.collection,
            field: props.data.field,
            gisJoin: props.data.gisJoin,
            perdiod: props.data.timePeriod,
            timestep: parseInt(props.data.timeStep)
        }

        return (
            <Grid item>
                <Paper className={classes.root}>
                    <Typography>{JSON.stringify(returnObj)}</Typography>
                </Paper>
            </Grid>
        )
    }

    else return null;
}