var panels = panels();
var sidebar = panels[panels.length - 1]; // Assuming the last created panel is our sidebar
sidebar.location = 'right';
sidebar.length = 250;
sidebar.thickness = 250; // Sidebars are often thicker
sidebar.alignment = 'center';
sidebar.hiding = 'none';
