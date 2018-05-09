/** index.js By Beginner Emain:zheng_jinfan@126.com HomePage:http://www.zhengjinfan.cn */
layui.config({
	base: '/xiaoqiang/web/luci/js/'
}).use(['element', 'layer', 'navbar', 'tab'], function() {
	var element = layui.element(),
		$ = layui.jquery,
		layer = layui.layer,
		navbar = layui.navbar(),
		tab = layui.tab({
			elem: '.admin-nav-card' //设置选项卡容器
		});
	//iframe自适应
	$(window).on('resize', function() {
		var $content = $('.admin-nav-card .layui-tab-content');
		//$content.height($(this).height() - 147);
		//$content.find('iframe').each(function() {
			//$(this).height($content.height());
		//});
	}).resize();

	//设置navbar
	navbar.set({
		elem: '#admin-navbar-side',
		//data: navs
		url: '/xiaoqiang/web/luci/js/nav.json'
	});
	//渲染navbar
	navbar.render();
	//监听点击事件

	element.on('tab(admin-tab)', function(data) {
		var $content = $('.admin-nav-card .layui-tab-content');
		var iframe=$content.find('layui-show');
		//console.log(iframe);
		var height=iframe.find('iframe').contents().find("form");//.getheight();
		//console.log(height);
		height=height.height();
		//ELEM.contentBox.find('iframe[data-id=' + globalTabIdIndex + ']').each(function() {
				//$(this).height(ELEM.contentBox.height());
				//var ifm = document.getElementById("main");
			//	console.log($(this).context.contentDocument.body.scrollHeight);
				//.contentDocument.body.scrollHeight);
			//	var subWeb = document.frames ? document.frames["mainweb"].document :$(this).contentDocument;
			//	if( subWeb != null) {
			//		$(this).height = subWeb.body.scrollHeight;
			//}
			//});
		//console.log(height);
		//var height=
		//$(".layui-tab-content").height(iframe);
		//$(window).resize();
	});

	//手机设备的简单适配
	var treeMobile = $('.site-tree-mobile'),
		shadeMobile = $('.site-mobile-shade');
	treeMobile.on('click', function() {
		$('body').addClass('site-mobile');
	});
	shadeMobile.on('click', function() {
		$('body').removeClass('site-mobile');
	});
});