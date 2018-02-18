import { h, render } from 'preact';
import Layout from './components/layout.js';

// Clear the contents of root (which contains a message about requiring JS)
let root = document.getElementById("root");
root.innerHTML = "";

render(<Layout />, root);
