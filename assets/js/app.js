import { h, render } from 'preact';
import { BrowserRouter } from 'react-router-dom';
import Layout from './views/layout.js';

// Clear the contents of root (which contains a message about requiring JS)
let root = document.getElementById("root");
root.innerHTML = "";

render(<BrowserRouter><Layout /></BrowserRouter>, root);
