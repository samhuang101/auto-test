var imgMap = {
    'controller': 'img/controller.png',
    'agent': 'img/agent.png',
    'client': 'img/client.png',
    'error-tip': 'img/error-tip.png',
    'link-cut': 'img/link-cut.png'
};

// TPChart 構造函數
function TPChart(option) {
	var _defaultOption = {
		width: 1000,
		height: 800,
		data: '',
		container: ''
	};

	option = $.extend(true, _defaultOption, option);

	this.width = option.width;
	this.height = option.height;
	this.data = option.data;
	this.container = option.container;
}

// 工具函數
function typeStr(obj) {
	return Object.prototype.toString.call(obj).toLowerCase();
}

// 多層網絡拓撲布局函數
function createMultiLevelLayout(nodes, links) {
	// 建立節點映射
	var nodeMap = {};
	nodes.forEach(function(node, index) {
		node.index = index;
		nodeMap[node.macaddr] = node;
	});

	// 找到根節點（controller）
	var rootNode = nodes.find(function(node) {
		return node.type === 'controller';
	});

	if (!rootNode) {
		rootNode = nodes[0];
	}

	// 建立樹狀結構
	var treeStructure = buildTreeStructure(nodes, links, rootNode);
	
	// 計算多層位置
	var layoutResult = calculateMultiLevelPositions(treeStructure);
	
	// 將位置信息複製回原始節點
	nodes.forEach(function(node) {
		var treeNode = findNodeInTree(layoutResult.root, node.macaddr);
		if (treeNode) {
			node.fx = treeNode.x;
			node.fy = treeNode.y;
			node.x = treeNode.x;
			node.y = treeNode.y;
		}
	});
	
	return layoutResult;
}

function findNodeInTree(root, macaddr) {
	if (root.macaddr === macaddr) {
		return root;
	}
	
	for (var i = 0; i < root.children.length; i++) {
		var found = findNodeInTree(root.children[i], macaddr);
		if (found) {
			return found;
		}
	}
	
	return null;
}

function buildTreeStructure(nodes, links, rootNode) {
	var visited = new Set();
	var nodeMap = {};
	
	// 初始化所有節點
	nodes.forEach(function(node) {
		nodeMap[node.macaddr] = {
			...node,
			children: [],
			parent: null,
			level: -1,
			connectionType: null
		};
	});

	// 設置根節點
	var root = nodeMap[rootNode.macaddr];
	root.level = 0;
	visited.add(rootNode.macaddr);

	// 建立節點索引映射
	var indexToMac = {};
	nodes.forEach(function(node, index) {
		indexToMac[index] = node.macaddr;
	});

	// 使用廣度優先搜索建立樹狀結構
	var queue = [root];
	
	while (queue.length > 0) {
		var currentNode = queue.shift();
		
		// 找到當前節點的所有子節點
		links.forEach(function(link) {
			// 處理不同的連接數據格式
			var sourceIndex, targetIndex;
			
			if (typeof link.source === 'object') {
				sourceIndex = link.source.index !== undefined ? link.source.index : link.source;
			} else {
				sourceIndex = link.source;
			}
			
			if (typeof link.target === 'object') {
				targetIndex = link.target.index !== undefined ? link.target.index : link.target;
			} else {
				targetIndex = link.target;
			}
			
			var connectionType = link.ifname || 'unknown';
			
			var sourceMac = indexToMac[sourceIndex];
			var targetMac = indexToMac[targetIndex];
			
			var childNode = null;
			var childMac = null;
			
			// 檢查連接方向，確定父子關係
			if (sourceMac === currentNode.macaddr && !visited.has(targetMac)) {
				childMac = targetMac;
				childNode = nodeMap[targetMac];
			} else if (targetMac === currentNode.macaddr && !visited.has(sourceMac)) {
				childMac = sourceMac;
				childNode = nodeMap[sourceMac];
			}
			
			if (childNode && childMac) {
				childNode.level = currentNode.level + 1;
				childNode.parent = currentNode;
				childNode.connectionType = connectionType;
				currentNode.children.push(childNode);
				visited.add(childMac);
				queue.push(childNode);
			}
		});
	}

	return root;
}

function calculateMultiLevelPositions(rootNode) {
	var centerX = 500;
	var startY = 100;
	var levelHeight = 150;
	
	// 收集所有層級的節點
	var levels = [];
	
	function collectLevels(node) {
		if (!levels[node.level]) {
			levels[node.level] = [];
		}
		levels[node.level].push(node);
		
		node.children.forEach(function(child) {
			collectLevels(child);
		});
	}
	
	collectLevels(rootNode);
	
	// 記錄每層已佔用的位置範圍
	var occupiedRanges = {};
	
	// 為每層計算位置
	levels.forEach(function(levelNodes, level) {
		if (!occupiedRanges[level]) {
			occupiedRanges[level] = [];
		}
		
		if (level === 0) {
			// 根節點居中
			levelNodes[0].x = centerX;
			levelNodes[0].y = startY;
			occupiedRanges[level].push({
				start: centerX - 40,
				end: centerX + 40,
				parentMac: levelNodes[0].macaddr
			});
		} else {
			// 根據層級計算最大範圍（越上層範圍越大）
			var baseRange = 500; // 基礎範圍
			var levelFactor = Math.max(0.3, 1 - (level - 1) * 0.2); // 層級係數，越下層越小
			var maxRange = baseRange * levelFactor;
			var minSpacing = Math.max(90, 140 - level * 15); // 增加最小間距，讓節點更寬
			
			
			// 按父節點分組
			var parentGroups = {};
			levelNodes.forEach(function(node) {
				if (node.parent) {
					var parentMac = node.parent.macaddr;
					if (!parentGroups[parentMac]) {
						parentGroups[parentMac] = [];
					}
					parentGroups[parentMac].push(node);
				}
			});
			
			// 按父節點 x 坐標排序處理
			var sortedParents = Object.keys(parentGroups).sort(function(a, b) {
				var parentA = parentGroups[a][0].parent;
				var parentB = parentGroups[b][0].parent;
				return parentA.x - parentB.x;
			});
			
			// 為每個分組分配位置
			sortedParents.forEach(function(parentMac) {
				var siblings = parentGroups[parentMac];
				var parent = siblings[0].parent;
				
				
				if (siblings.length === 1) {
					// 單個子節點：優先放在父節點正下方，如果衝突則調整
					var preferredX = parent.x;
					var finalX = findNonOverlappingPosition(preferredX, occupiedRanges[level], minSpacing);
					
					siblings[0].x = finalX;
					siblings[0].y = startY + level * levelHeight;
					
					// 記錄佔用範圍
					occupiedRanges[level].push({
						start: finalX - minSpacing/2,
						end: finalX + minSpacing/2,
						parentMac: parent.macaddr
					});
					
				} else {
					// 多個子節點：以父節點為中心對稱分佈
					var childSpacing = minSpacing;
					
					// 如果子節點太多，調整間距
					var totalWidth = (siblings.length - 1) * childSpacing;
					if (totalWidth > maxRange * 2) {
						childSpacing = (maxRange * 2) / (siblings.length - 1);
					}
					
					var idealStartX = parent.x - totalWidth / 2;
					var idealEndX = parent.x + totalWidth / 2;
					
					// 檢查是否與已有範圍衝突
					var groupRange = {
						start: idealStartX - minSpacing/2,
						end: idealEndX + minSpacing/2
					};
					
					var adjustedStartX = findNonOverlappingRangePosition(groupRange, occupiedRanges[level]);
					var actualStartX = adjustedStartX + minSpacing/2;
					
					siblings.forEach(function(sibling, index) {
						sibling.x = actualStartX + index * childSpacing;
						sibling.y = startY + level * levelHeight;
					});
					
					// 記錄整個分組的佔用範圍
					occupiedRanges[level].push({
						start: adjustedStartX,
						end: adjustedStartX + (idealEndX - idealStartX) + minSpacing,
						parentMac: parent.macaddr
					});
				}
			});
			
		}
	});
	
	return {
		root: rootNode
	};
}

// 尋找不重疊的單點位置
function findNonOverlappingPosition(preferredX, occupiedRanges, minSpacing) {
	// 檢查首選位置是否可用
	if (!isPositionConflict(preferredX, occupiedRanges, minSpacing)) {
		return preferredX;
	}
	
	// 向左右交替尋找可用位置
	for (var offset = minSpacing; offset <= 300; offset += minSpacing) {
		// 先試右邊
		var rightX = preferredX + offset;
		if (!isPositionConflict(rightX, occupiedRanges, minSpacing)) {
			return rightX;
		}
		
		// 再試左邊
		var leftX = preferredX - offset;
		if (!isPositionConflict(leftX, occupiedRanges, minSpacing)) {
			return leftX;
		}
	}
	
	// 如果都不行，返回首選位置
	return preferredX;
}

// 尋找不重疊的範圍位置
function findNonOverlappingRangePosition(range, occupiedRanges) {
	var rangeWidth = range.end - range.start;
	
	// 檢查原位置是否可用
	if (!isRangeConflict(range, occupiedRanges)) {
		return range.start;
	}
	
	// 向右尋找可用位置
	for (var offset = 50; offset <= 400; offset += 50) {
		var newRange = {
			start: range.start + offset,
			end: range.start + offset + rangeWidth
		};
		
		if (!isRangeConflict(newRange, occupiedRanges)) {
			return newRange.start;
		}
	}
	
	// 如果都不行，返回原位置
	return range.start;
}

// 檢查單點位置是否衝突
function isPositionConflict(x, occupiedRanges, minSpacing) {
	for (var i = 0; i < occupiedRanges.length; i++) {
		var range = occupiedRanges[i];
		if (x >= range.start - minSpacing/2 && x <= range.end + minSpacing/2) {
			return true;
		}
	}
	return false;
}

// 檢查範圍是否衝突
function isRangeConflict(newRange, occupiedRanges) {
	for (var i = 0; i < occupiedRanges.length; i++) {
		var existingRange = occupiedRanges[i];
		// 檢查是否有重疊
		if (!(newRange.end <= existingRange.start || newRange.start >= existingRange.end)) {
			return true;
		}
	}
	return false;
}

// TPChart 原型方法
TPChart.prototype.init = function () {
	var _this = this;
	if (typeStr(_this.data) == '[object string]') {
		d3.json(_this.data, function (error, data) {
			if (error) throw error;
			_this.data = data;
			_this.render(_this.data.nodes, _this.data.lines);
		});
	} else if(typeStr(_this.data) == '[object object]') {
		_this.render(_this.data.nodes, _this.data.lines);
	}
};

TPChart.prototype.render = function (nodes, lines) {
	var _this = this,
		width = _this.width,
		height = _this.height,
		svg = d3.select(_this.container).append("svg")
		.attr("width", width)
		.attr("height", height)
		.style("background-color", "#ffffff"),
		graph = svg.append("g").attr("class", "graph")
		.style("pointer-events", "all");

	// 添加網格背景
	var defs = svg.append("defs");
	var pattern = defs.append("pattern")
		.attr("id", "grid")
		.attr("width", 20)
		.attr("height", 20)
		.attr("patternUnits", "userSpaceOnUse");
	
	pattern.append("path")
		.attr("d", "M 20 0 L 0 0 0 20")
		.attr("fill", "none")
		.attr("stroke", "#e0e0e0")
		.attr("stroke-width", 0.5)
		.attr("opacity", 0.3);

	svg.append("rect")
		.attr("width", "100%")
		.attr("height", "100%")
		.attr("fill", "url(#grid)")
		.style("pointer-events", "none");

	// 創建多層布局
	var layoutStructure = createMultiLevelLayout(nodes, lines);

	// 創建直接連接線
	var directLines = [];
	
	function createDirectConnections(node) {
		node.children.forEach(function(child) {
			directLines.push({
				x1: node.x,
				y1: node.y + 25,
				x2: child.x,
				y2: child.y - 25,
				connectionType: child.connectionType,
				parentMac: node.macaddr,
				childMac: child.macaddr
			});
			
			// 遞歸處理子節點
			createDirectConnections(child);
		});
	}
	
	createDirectConnections(layoutStructure.root);
	
	// 繪製直接連接線
	var _g_lines = graph.selectAll("g.direct-line")
		.data(directLines)
		.enter()
		.append("g")
		.attr("class", "direct-line");

	_g_lines.append("line")
		.attr("x1", function(d) { return d.x1; })
		.attr("y1", function(d) { return d.y1; })
		.attr("x2", function(d) { return d.x2; })
		.attr("y2", function(d) { return d.y2; })
		.style('stroke', function (d) {
			// 統一使用藍色，不再區分 Ethernet 和 WLAN
			return '#2196F3';
		})
		.style("stroke-width", 1) // 連接線變細，從 2 改為 1
		.style('stroke-dasharray', function(d) {
			// 根據連接類型設置線型
			if (d.connectionType && (d.connectionType.includes('WLAN') || d.connectionType === '2.4G' || d.connectionType === '5G' || d.connectionType === '6G')) {
				return '8,4'; // WLAN 用虛線
			} else if (d.connectionType && (d.connectionType === 'Eth' || d.connectionType === 'ETHER' || d.connectionType === 'Ethernet')) {
				return 'none'; // Ethernet 用實線，但顏色改為藍色
			} else {
				return '8,4'; // 默認虛線
			}
		})
		.style('opacity', 0.8);



	var _g_nodes = graph.selectAll("g.node")
		.data(nodes)
		.enter()
		.append("g")
		.attr("class", "node")
		.attr("transform", function(d) {
			return "translate(" + d.x + "," + d.y + ")";
		});


	// 創建設備節點容器
	var nodeContainer = _g_nodes.append("g")
		.attr("class", "node-container")
		.style("pointer-events", "all");


	// 添加設備背景框
	var rects = nodeContainer.append("rect")
		.attr("width", function(d) {
			return d.type === 'controller' ? 80 : 60;
		})
		.attr("height", function(d) {
			return d.type === 'controller' ? 60 : 50;
		})
		.attr("rx", 4)
		.attr("ry", 4)
		.attr("fill", "#f5f5f5")
		.attr("stroke", "none")
		.style("opacity", 0.9)
		.style("pointer-events", "all")
		.style("cursor", "pointer");


	// 添加設備圖標
	nodeContainer.append("image")
		.attr("width", function (d) {
			return d.type === 'controller' ? 32 : 24;
		})
		.attr("height", function (d) {
			return d.type === 'controller' ? 32 : 24;
		})
		.attr("xlink:href", function (d) {
			return imgMap[d.type] || imgMap['client'];
		})
		.attr("x", function(d) {
			var boxWidth = d.type === 'controller' ? 80 : 60;
			var iconWidth = d.type === 'controller' ? 32 : 24;
			return (boxWidth - iconWidth) / 2;
		})
		.attr("y", 8)
		.style("pointer-events", "none");

	// 添加設備名稱
	nodeContainer.append("text")
		.text(function (d) {
			// 优先使用 DevName，如果没有则使用 hostname，最后才使用 MAC 地址
			var displayName = d.DevName || d.hostname;

			if (!displayName || displayName === "" || displayName === "undefined" || displayName === "null") {
				return d.macaddr ? d.macaddr.substring(d.macaddr.length - 5) : 'N/A';
			} else {
				return displayName;
			}
		})
		.style('font-size', '11px')
		.style('fill', '#333333')
		.style('font-family', 'Arial, sans-serif')
		.style('text-anchor', 'middle')
		.style('pointer-events', 'none')
		.attr("x", function(d) {
			return d.type === 'controller' ? 40 : 30;
		})
		.attr("y", function(d) {
			return d.type === 'controller' ? 50 : 42;
		});

	// 添加狀態指示器 - 只保留離線狀態的紅色圓點
	nodeContainer.each(function (d, i) {
		var selection = d3.select(this);
		var containerNode = this;


		if (d.status == '0') {
			selection.append("circle")
				.attr("cx", function(d) {
					return d.type === 'controller' ? 70 : 50;
				})
				.attr("cy", 5)
				.attr("r", 4)
				.attr("fill", "#ff4444")
				.append("title")
				.text("設備離線");
		}
		// 移除了原來的 else 部分，不再顯示綠色的在線狀態指示器
	});

	// 設置節點位置
	_g_nodes.attr("transform", function (d) {
		var nodeWidth = d.type === 'controller' ? 80 : 60;
		var nodeHeight = d.type === 'controller' ? 60 : 50;
		return 'translate(' + (d.fx - nodeWidth / 2) + ',' + (d.fy - nodeHeight / 2) + ')';
	});

	// 添加縮放行為（禁用雙擊縮放）
	var zoom = getZoomBehavior(graph);
	svg.call(zoom);
	svg.on("dblclick.zoom", null); // 禁用雙擊縮放

	// 鼠標懸停效果
	nodeContainer.on('mouseenter', function (d) {
		d3.select(this).style("cursor", "pointer");
		d3.select(this).select("rect")
			.transition()
			.duration(200)
			.attr("fill", "#e8e8e8")
			.style("opacity", 1);

		$(_this.container).append(createInfoTip(d));
	});

	nodeContainer.on('mouseleave', function () {
		d3.select(this).select("rect")
			.transition()
			.duration(200)
			.attr("fill", "#f5f5f5")
			.style("opacity", 0.9);

		$(".dialog-footer").html("");
	});

	// 點擊節點顯示詳細資訊
	nodeContainer.on('click', function (d) {

		// 防止事件冒泡
		if (d3.event) {
			d3.event.stopPropagation();
		}

		showDeviceInfo(d);
	});

	// 點擊空白處關閉彈出窗口
	svg.on('click', function() {
		var popups = document.querySelectorAll('.device-info-popup');
		popups.forEach(function(popup) {
			popup.remove();
		});
	});
};

// 顯示設備詳細資訊的函數
function showDeviceInfo(d) {
	console.log('showDeviceInfo 被調用:', d);

	// 移除現有的彈出窗口
	var existingPopups = document.querySelectorAll('.device-info-popup');
	existingPopups.forEach(function(popup) {
		popup.remove();
	});

	// 準備資訊數據
	var displayName = d.DevName || d.hostname || (d.macaddr ? d.macaddr.substring(d.macaddr.length - 5) : 'N/A');
	var status = d.info && d.info.netstatus ? d.info.netstatus : (d.status == '0' ? 'offline' : 'online');
	var statusColor = status === 'offline' ? '#ff4444' : '#4CAF50';
	var rssi = d.info && d.info.rssi ? d.info.rssi + ' dBm' : 'Unknown';
	var channel = d.info && d.info.channel ? d.info.channel : 'Unknown';
	var ifname = d.info && d.info.ifname ? d.info.ifname : (d.ifname || 'N/A');

	// 判斷連線類型是否為 ETH
	var isEthConnection = ifname && ifname.includes('Eth');
	if (isEthConnection) {
		ifname = "ETHER";
	}
	// 創建 HTML 內容
	var htmlContent = '<div class="device-info-popup" style="position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: #ffffff; border: 2px solid #2196F3; border-radius: 8px; padding: 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.2); z-index: 10000; min-width: 350px; max-width: 500px;">';

	htmlContent += '<h3 style="margin: 0 0 15px 0; color: #2196F3; font-size: 18px; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">Device Information</h3>';

	htmlContent += '<div style="margin-bottom: 15px;">';
	htmlContent += createInfoRowHTML('Device Name', displayName);
	htmlContent += createInfoRowHTML('Device Type', d.type || 'Unknown');
	htmlContent += createInfoRowHTML('MAC Address', d.macaddr || 'Unknown');
	//htmlContent += createInfoRowHTML('Status', status, statusColor);
	htmlContent += createInfoRowHTML('Connection Type', ifname);

	// 只有非 ETH 連線才顯示 Channel 和 RSSI
	if (d.type !== 'controller' && !isEthConnection) {
		htmlContent += createInfoRowHTML('Channel', channel);
		htmlContent += createInfoRowHTML('RSSI', rssi);
	}

	htmlContent += '</div>';

	htmlContent += '<button class="close-popup-btn" style="width: 100%; padding: 10px; background: #2196F3; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold;" onmouseover="this.style.background=\'#1976D2\'" onmouseout="this.style.background=\'#2196F3\'">Close</button>';

	htmlContent += '</div>';

	// 添加彈窗到 body
	var tempDiv = document.createElement('div');
	tempDiv.innerHTML = htmlContent;
	var popup = tempDiv.firstChild;
	document.body.appendChild(popup);

	// 關閉彈窗的函數
	function closePopup() {
		popup.remove();
		document.removeEventListener('visibilitychange', handleVisibilityChange);
	}

	// 監聽頁面可見性變化
	function handleVisibilityChange() {
		if (document.hidden) {
			closePopup();
		}
	}
	document.addEventListener('visibilitychange', handleVisibilityChange);

	// 點擊關閉按鈕
	popup.querySelector('.close-popup-btn').addEventListener('click', closePopup);
}

// 創建資訊行 HTML 的輔助函數
function createInfoRowHTML(label, value, color) {
	var valueColor = color || '#333';
	var fontWeight = color ? 'bold' : 'normal';
	return '<div style="display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f0f0f0;">' +
		'<span style="font-weight: bold; color: #666;">' + label + ':</span>' +
		'<span style="color: ' + valueColor + '; font-weight: ' + fontWeight + ';">' + value + '</span>' +
		'</div>';
}

// 創建縮放行為
function getZoomBehavior(g) {
	return d3.behavior.zoom()
		.scaleExtent([0.5, 3])
		.on("zoom", zoomEvtFn);

	function zoomEvtFn() {
		g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
	}
}

function createInfoTip(node) {
	var security_5g, security_2g;
	if (node.type == "agent"){
		if(node.info && node.info.security_5g){
			if(node.info.security_5g == "mixed3"){
				security_5g = "WPA3/WPA2 PSK";
			}else if(node.info.security_5g == "wpa3"){
				security_5g = "WPA3 PSK";
			}else if(node.info.security_5g == "mixed2"){
				security_5g = "WPA2/WPA PSK";
			}else if(node.info.security_5g == "wpa2"){
				security_5g = "WPA2 PSK";
			}else if(node.info.security_5g == "open"){
				security_5g = "OPEN";
			}else{
				security_5g = node.info.security_5g;
			}
		}
		if(node.info && node.info.security_2g){
			if(node.info.security_2g == "mixed3"){
				security_2g = "WPA3/WPA2 PSK";
			}else if(node.info.security_2g == "wpa3"){
				security_2g = "WPA3 PSK";
			}else if(node.info.security_2g == "mixed2"){
				security_2g = "WPA2/WPA PSK";
			}else if(node.info.security_2g == "wpa2"){
				security_2g = "WPA2 PSK";
			}else if(node.info.security_2g == "open"){
				security_2g = "OPEN";
			}else{
				security_2g = node.info.security_2g;
			}
		}
	}
	
	var status = node.info && node.info.netstatus ? node.info.netstatus : (node.status == '0' ? 'offline' : 'online');
	$(".dialog-footer").html("狀態: " + status + "<br>類型: " + node.type + "<br>MAC: " + (node.macaddr || 'N/A'));
	
	var html = '<div class="node-info" style="background: #ffffff; color: #333; padding: 10px; border-radius: 4px; border: 1px solid #ccc;"><ul style="margin: 0; padding: 0; list-style: none;">';
	html += '<li style="margin-bottom: 5px;"><span class="info-title" style="color: #2196F3;">狀態:</span><span class="info-content" style="margin-left: 10px;">' + status + '</span></li>';
	html += '<li style="margin-bottom: 5px;"><span class="info-title" style="color: #2196F3;">類型:</span><span class="info-content" style="margin-left: 10px;">' + node.type + '</span></li>';
	if(node.macaddr) {
		html += '<li><span class="info-title" style="color: #2196F3;">MAC:</span><span class="info-content" style="margin-left: 10px;">' + node.macaddr + '</span></li>';
	}
	html += '</ul></div>';

	return html;
}

// 直線方程求x值
function x_linearEquation(x1, y1, x2, y2, y) {
	var a = y2 - y1,
		b = x1 - x2,
		c = x2 * y1 - x1 * y2;

	return -(c + b * y) / a;
}

// 直線方程求y值
function y_linearEquation(x1, y1, x2, y2, x) {
	var a = y2 - y1,
		b = x1 - x2,
		c = x2 * y1 - x1 * y2;

	return -(c + a * x) / b;
}