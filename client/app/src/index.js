import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import {sendEchoRequest} from './utils/requests';

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);

reportWebVitals();

const echoQuery = (param) => sendEchoRequest(param);
window.echoQuery = echoQuery