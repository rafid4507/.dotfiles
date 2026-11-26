function moveWindowBy(desktops) {
    var win = workspace.activeWindow;
    if (!win || win.desktops.length === 0) return;
    var current = win.desktops[0];
    var all = workspace.desktops;
    var idx = -1;
    for (var i = 0; i < all.length; i++) {
        if (all[i] === current || all[i].id === current.id) { idx = i; break; }
    }
    if (idx < 0) return;
    var len = all.length;
    var target = ((idx + desktops) % len + len) % len;
    if (target === idx) return;
    win.desktops = [all[target]];
    workspace.currentDesktop = all[target];
}

registerShortcut("MoveWindow2DesktopsUp", "Move Window 2 Desktops Up", "Meta+Ctrl+U", function() { moveWindowBy(-2); });
registerShortcut("MoveWindow2DesktopsDown", "Move Window 2 Desktops Down", "Meta+Ctrl+I", function() { moveWindowBy(2); });
