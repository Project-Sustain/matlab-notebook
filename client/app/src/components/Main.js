import React, { useEffect, useState, useRef } from 'react';
import {Grid, makeStyles, Paper, Typography} from "@material-ui/core";

const useStyles = makeStyles({
    root: {
        width: "50vw",
        margin: "20px",
        padding: "20px",
    },
});

export default function Main() {
    const classes = useStyles();

    return (
        <Grid container direction="row" justifyContent="center" alignItems="center">
            <Paper className={classes.root}>
                <Typography>Here is a thing</Typography>
            </Paper>
        </Grid>
    )
}