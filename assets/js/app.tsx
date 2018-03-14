import { h, render } from 'preact';
import { BrowserRouter } from 'react-router-dom';
import Layout from './views/layout';

// Clear the contents of root (which contains a message about requiring JS)
const root = document.getElementById("root");
render(<BrowserRouter><Layout /></BrowserRouter>, null, root);
