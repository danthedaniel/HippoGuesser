import { h, render } from 'preact';
import { BrowserRouter } from 'react-router-dom';
import Layout from './views/layout';
import { init } from './api/gateway';

const url = (() => {
  switch (process.env.NODE_ENV) {
    case "development":
      return "http://localhost:4000/api";
    case "production":
      return "https://mtpo.teaearlgraycold.me/api";
    default:
      throw "Environment not recognized.";
  }
})();

init({url, fetchOptions: {credentials: "same-origin"}});

// Replace the contents of root (which contains a message about requiring JS)
const root = document.getElementById("root");
render(<BrowserRouter><Layout /></BrowserRouter>, null, root);
