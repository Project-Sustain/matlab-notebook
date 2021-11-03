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
    if(props.state.open) {
        const bracketLeft = "{"
        const bracketRight = "}"
        return (
            <Grid item>
                <Paper elevation={3} className={classes.root}>
                    <Grid container direction="column" justifyContent="flex-start" alignItems="flex-start">
                        <Typography>{bracketLeft}</Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"collection": "{props.state.collection}",
                        </Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"field": "{props.state.field}",
                        </Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"gisJoin": "{props.state.gisJoin}",
                        </Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"perdiod": "{props.state.timePeriod}",
                        </Typography>
                        <Typography>
                            &emsp;&emsp;&emsp;&emsp;"timestep": {parseInt(props.state.timeStep)}
                        </Typography>
                        <Typography>{bracketRight}</Typography>
                    </Grid>
                    <Button className={classes.button} variant="outlined" onClick={() => props.state.setOpen(false)}>Close</Button>
                </Paper>
            </Grid>
        )
    }

    else return null;
}