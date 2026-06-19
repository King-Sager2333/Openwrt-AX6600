'use strict';
'require view';
'require rpc';
'require dom';
'require poll';
'require ui';

// 定义 ubus 远程过程调用接口
var callGetConnections = rpc.declare({
    object: 'netmonitor',
    method: 'get_connections',
    expect: { connections: [] }
});

var callDisconnect = rpc.declare({
    object: 'netmonitor',
    method: 'disconnect',
    params: [ 'src', 'dst', 'sport', 'dport', 'proto' ],
    expect: { success: false }
});

var callStartCapture = rpc.declare({
    object: 'netmonitor',
    method: 'start_capture',
    expect: { success: false }
});

var callStopCapture = rpc.declare({
    object: 'netmonitor',
    method: 'stop_capture',
    expect: { success: false }
});

var callGetLogs = rpc.declare({
    object: 'netmonitor',
    method: 'get_logs',
    params: [ 'offset' ],
    expect: { logs: "", offset: 0 }
});

return view.extend({
    // 全局状态变量
    isPaused: false,
    isCapturing: false,
    logOffset: 0,
    currentSortCol: 'dst',
    currentSortDesc: false,
    expandedHosts: {}, // 记录主机的折叠状态

    // 渲染主视图
    render: function() {
        var m, s, o;

        // 创建主容器
        var container = E('div', { 'class': 'cbi-map', 'id': 'map' }, [
            E('h2', _('Deep Connection Monitor')),
            E('div', { 'class': 'cbi-map-descr' }, _('A powerful tool for real-time connection management and network debugging.'))
        ]);

        // 控制面板：抓包控制和刷新控制
        var controlPanel = E('div', { 'class': 'cbi-section' }, [
            E('h3', _('Control Panel')),
            E('div', { 'class': 'cbi-section-node' }, [
                E('div', { 'class': 'cbi-value' }, [
                    E('label', { 'class': 'cbi-value-title' }, _('Real-time Capture')),
                    E('div', { 'class': 'cbi-value-field' }, [
                        E('button', {
                            'class': 'btn cbi-button cbi-button-apply',
                            'id': 'btn-capture',
                            'click': L.bind(this.handleCaptureToggle, this)
                        }, _('Start Capture'))
                    ])
                ]),
                E('div', { 'class': 'cbi-value' }, [
                    E('label', { 'class': 'cbi-value-title' }, _('Refresh Control')),
                    E('div', { 'class': 'cbi-value-field' }, [
                        E('button', {
                            'class': 'btn cbi-button',
                            'id': 'btn-pause',
                            'click': L.bind(this.handlePauseToggle, this)
                        }, _('Pause Refresh'))
                    ])
                ])
            ])
        ]);
        container.appendChild(controlPanel);

        // 连接列表容器
        var connPanel = E('div', { 'class': 'cbi-section' }, [
            E('h3', _('Connections')),
            E('div', { 'class': 'cbi-section-node', 'id': 'connections-container' }, [
                E('em', _('Loading...'))
            ])
        ]);
        container.appendChild(connPanel);

        // 调试日志区域
        var logPanel = E('div', { 'class': 'cbi-section' }, [
            E('h3', _('Debug Log')),
            E('div', { 'class': 'cbi-section-node' }, [
                E('textarea', {
                    'id': 'debug-log',
                    'readonly': 'readonly',
                    'style': 'width: 100%; height: 200px; font-family: monospace; resize: vertical;'
                })
            ])
        ]);
        container.appendChild(logPanel);

        // 设置定时任务
        poll.add(L.bind(this.updateData, this), 2); // 每 2 秒刷新一次数据
        poll.add(L.bind(this.updateLogs, this), 1); // 每 1 秒拉取一次增量日志

        return container;
    },

    // 处理抓包开关点击
    handleCaptureToggle: function(ev) {
        var btn = ev.target;
        if (this.isCapturing) {
            callStopCapture().then(L.bind(function(res) {
                if (res) {
                    this.isCapturing = false;
                    btn.textContent = _('Start Capture');
                    btn.classList.remove('cbi-button-negative');
                    btn.classList.add('cbi-button-apply');
                }
            }, this));
        } else {
            callStartCapture().then(L.bind(function(res) {
                if (res) {
                    this.isCapturing = true;
                    btn.textContent = _('Stop Capture');
                    btn.classList.remove('cbi-button-apply');
                    btn.classList.add('cbi-button-negative');
                }
            }, this));
        }
    },

    // 处理刷新暂停点击
    handlePauseToggle: function(ev) {
        var btn = ev.target;
        this.isPaused = !this.isPaused;
        if (this.isPaused) {
            btn.textContent = _('Resume Refresh');
            btn.classList.add('cbi-button-action');
        } else {
            btn.textContent = _('Pause Refresh');
            btn.classList.remove('cbi-button-action');
        }
    },

    // 排序辅助函数
    setSort: function(col) {
        if (this.currentSortCol === col) {
            this.currentSortDesc = !this.currentSortDesc;
        } else {
            this.currentSortCol = col;
            this.currentSortDesc = false;
        }
        // 强制触发一次更新
        this.updateData();
    },

    // 核心数据更新逻辑
    updateData: function() {
        if (this.isPaused) {
            return Promise.resolve();
        }

        return callGetConnections().then(L.bind(function(conns) {
            var container = document.getElementById('connections-container');
            if (!container) return;

            // 按主机 (host) 分组
            var groups = {};
            conns.forEach(function(c) {
                if (!groups[c.host]) {
                    groups[c.host] = [];
                }
                groups[c.host].push(c);
            });

            // 重新构建视图
            var fragment = document.createDocumentFragment();

            Object.keys(groups).sort().forEach(L.bind(function(host) {
                var hostConns = groups[host];

                // 对组内连接进行排序
                hostConns.sort(L.bind(function(a, b) {
                    var valA = a[this.currentSortCol] || '';
                    var valB = b[this.currentSortCol] || '';
                    if (valA < valB) return this.currentSortDesc ? 1 : -1;
                    if (valA > valB) return this.currentSortDesc ? -1 : 1;
                    return 0;
                }, this));

                // 恢复之前的折叠状态（默认展开）
                var isExpanded = this.expandedHosts[host] !== false;

                // 创建主机的折叠面板标题
                var hostHeader = E('h4', {
                    'style': 'cursor: pointer; background: #f0f0f0; padding: 5px; margin-top: 10px; border-radius: 3px;',
                    'click': L.bind(function(ev) {
                        var table = ev.target.nextElementSibling;
                        if (table.style.display === 'none') {
                            table.style.display = 'table';
                            this.expandedHosts[host] = true;
                        } else {
                            table.style.display = 'none';
                            this.expandedHosts[host] = false;
                        }
                    }, this)
                }, host + ' (' + hostConns.length + ')');

                // 创建连接表格
                var table = E('table', { 'class': 'table cbi-section-table', 'style': 'width: 100%; display: ' + (isExpanded ? 'table' : 'none') + ';' }, [
                    E('tr', { 'class': 'tr table-titles' }, [
                        E('th', { 'class': 'th', 'style': 'cursor:pointer', 'click': L.bind(this.setSort, this, 'target_url') }, _('Target Address') + (this.currentSortCol==='target_url'?(this.currentSortDesc?' ▼':' ▲'):'')),
                        E('th', { 'class': 'th', 'style': 'cursor:pointer', 'click': L.bind(this.setSort, this, 'dst') }, _('Target IP') + (this.currentSortCol==='dst'?(this.currentSortDesc?' ▼':' ▲'):'')),
                        E('th', { 'class': 'th', 'style': 'cursor:pointer', 'click': L.bind(this.setSort, this, 'proto') }, _('Type') + (this.currentSortCol==='proto'?(this.currentSortDesc?' ▼':' ▲'):'')),
                        E('th', { 'class': 'th', 'style': 'cursor:pointer', 'click': L.bind(this.setSort, this, 'timeout') }, _('TTL/Timeout') + (this.currentSortCol==='timeout'?(this.currentSortDesc?' ▼':' ▲'):'')),
                        E('th', { 'class': 'th', 'style': 'cursor:pointer', 'click': L.bind(this.setSort, this, 'status') }, _('Status') + (this.currentSortCol==='status'?(this.currentSortDesc?' ▼':' ▲'):'')),
                        E('th', { 'class': 'th' }, _('Action'))
                    ])
                ]);

                hostConns.forEach(L.bind(function(c) {
                    var tr = E('tr', { 'class': 'tr' }, [
                        E('td', { 'class': 'td' }, c.target_url || '-'),
                        E('td', { 'class': 'td' }, c.dst + ':' + c.dport),
                        E('td', { 'class': 'td' }, c.proto.toUpperCase()),
                        E('td', { 'class': 'td' }, c.timeout + 's'),
                        E('td', { 'class': 'td' }, c.status),
                        E('td', { 'class': 'td' }, [
                            E('button', {
                                'class': 'btn cbi-button cbi-button-remove',
                                'click': function(ev) {
                                    ev.stopPropagation();
                                    callDisconnect(c.src, c.dst, c.sport, c.dport, c.proto).then(function(res) {
                                        if (res) {
                                            ui.addNotification(null, E('p', _('Connection disconnected.')), 'info');
                                        } else {
                                            ui.addNotification(null, E('p', _('Failed to disconnect.')), 'danger');
                                        }
                                    });
                                }
                            }, _('Disconnect'))
                        ])
                    ]);
                    table.appendChild(tr);
                }, this));

                fragment.appendChild(hostHeader);
                fragment.appendChild(table);
            }, this));

            dom.content(container, fragment);
        }, this));
    },

    // 增量更新日志
    updateLogs: function() {
        if (!this.isCapturing) {
            return Promise.resolve();
        }

        return callGetLogs(this.logOffset).then(L.bind(function(res) {
            if (res && res.logs && res.logs.length > 0) {
                var logArea = document.getElementById('debug-log');
                if (logArea) {
                    // 解码 base64
                    try {
                        var decodedLogs = atob(res.logs);
                        logArea.value += decodedLogs;
                        // 自动滚动到底部
                        logArea.scrollTop = logArea.scrollHeight;
                    } catch (e) {
                        console.error('Base64 decode error: ', e);
                    }
                }
            }
            if (res && typeof res.offset !== 'undefined') {
                this.logOffset = res.offset;
            }
        }, this));
    },

    handleSaveApply: null,
    handleSave: null,
    handleReset: null
});
