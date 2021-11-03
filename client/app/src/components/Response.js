import React from 'react';
import {Button, Grid, makeStyles, Paper, Typography} from "@material-ui/core";

const useStyles = makeStyles({
    root: {
        width: "50vw",
        margin: "20px",
        padding: "20px",
    },
    button: {
        marginTop: "10px"
    }
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

        const bracketLeft = "{"
        const bracketRight = "}"
        return (
            <Grid item>
                <Paper className={classes.root}>
                    <Grid container direction="column" justifyContent="flex-start" alignItems="flex-start">
                        <Typography>{bracketLeft}</Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"collection": {props.data.collection},
                        </Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"field": {props.data.field},
                        </Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"gisJoin": {props.data.gisJoin},
                        </Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"perdiod": {props.data.timePeriod},
                        </Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"timestep": {parseInt(props.data.timeStep)}
                        </Typography>
                        <Typography>{bracketRight}</Typography>
                    </Grid>
                    {/*<Typography>{JSON.stringify(returnObj)}</Typography>*/}
                    <Button className={classes.button} variant="outlined" onClick={() => props.data.setResponse(false)}>Close</Button>
                </Paper>
            </Grid>
        )
    }

    else return null;
}

function text(props) {
    return <Typography>{props.children}</Typography>
}