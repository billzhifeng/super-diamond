<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<% pageContext.setAttribute("newLineChar", "\r\n"); %>
<% pageContext.setAttribute("newLineChar2", "\n"); %>

<ol class="breadcrumb">
	<li><a href="/index">首页</a></li>
	<li class="active"><c:out value="${project.PROJ_NAME}"/> - <c:out value="${type}"/></li>
</ol>

<form class="form-inline" style="padding-bottom: 10px">
	<div class="form-group">
		<label for="sel-queryModule">模块：</label>
		<select id="sel-queryModule" class="selectpicker" data-live-search="true">
			<option value="">全部</option>
			<c:forEach items="${modules}" var="module">
				<option value='<c:out value="${module.moduleId}"/>' ${module.moduleId eq moduleId?'selected':''}><c:out value="${module.moduleName}"/></option>
			</c:forEach>
		</select>
	</div>
	<div class="form-group" style="padding-left:5px;">
		<label for="confKey">KEY：</label>
		<input id="confKey" name="confKey" value="${confKey}" placeholder="KEY" class="typeahead form-control" style="width:300px;">
	</div>
	<button type="button" class="btn btn-primary" onclick="doSearch()">查询</button>
	<div class="form-group btn-group">
		<button type="button" id="addConfig" class="btn btn-primary" onclick="show()">添加配置</button>
		<button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
			<span class="caret"></span>
			<span class="sr-only">Toggle Dropdown</span>
		</button>
		<ul class="dropdown-menu" role="menu">
			<li><a id="preview">预览</a></li>
			<li><a id="deploy">发布</a></li>
			<li class="divider"></li>
			<li><a id="addModule" href="javascript:showModule()">添加module</a></li>
			<li><a id="delModule" href="javascript:void(0)">删除module</a></li>
		</ul>
	</div>
</form>

<!-- <button type="button" id="queryModule" class="btn btn-primary">查询</button> -->
<!-- <a id="deleteModule" href="javascript:void(0)">删除Module</a> -->
<div id="addModalWin" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
	<div class="modal-header">
    	<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
    	<h3 id="myModalLabel">添加Module</h3>
  	</div>
  	<div class="modal-body">
    	<form id="moduleForm" class="form-horizontal" action='<c:url value="/module/save" />' method="post">
			<div class="form-group">
    				<input type="hidden" name="projectId" value='<c:out value="${projectId}"/>'/>
    				<input type="hidden" name="type" value='<c:out value="${type}"/>'/>
					<label for="addModuleName" class="col-sm-2 control-label">名称：</label>
				    <div class="col-sm-8">
				    <input type="text" id="addModuleName" name="name" class="form-control">
					<span id="addTip" style="color: red"></span>
				    </div>
			</div>
		</form>
  	</div>
  	<div class="modal-footer">
    	<button class="btn" data-dismiss="modal" aria-hidden="true">关闭</button>
    	<button class="btn btn-primary" id="saveModule">保存</button>
  	</div>
			</div>
		</div>
</div>

<jsp:include page="addConfigWin.jsp">
    <jsp:param name="version" value="${project.DEVELOPMENT_VERSION}"/>
	<jsp:param name="confKey" value="${confKey}"/>
</jsp:include>

<jsp:include page="editConfigWin.jsp">
  <jsp:param name="version" value="${project.DEVELOPMENT_VERSION}"/>
</jsp:include>
<input type="hidden" id="moduleId" name="moduleId" value="${moduleId}"/>
<input type="hidden" id="pageNumber" name="pageNumber" value="${pageNumber}"/>
<table class="table table-striped table-bordered table-hover">
  	<thead>
    	<tr>
    		<th width="90">Module</th>
      		<th width="80">Key</th>
      		<th width="80">Value</th>
      		<th>描述</th>
      		<th>操作人</th>
      		<th width="150">操作时间</th>
      		<th width="50">操作</th>
    	</tr>
  	</thead>
  	<tbody>
    	<c:forEach items="${pagelist.result}" var="config">
    		<tr id='row-<c:out value="${config.configId}"/>'>
               	<td value='<c:out value="${config.moduleId}"/>'>
                  	<c:out value="${config.moduleName}"/>
               	</td>
               	<td value='<c:out value="${config.configKey}"/>'>
               		<c:out value="${config.configKey}"/>
               	</td>
               	<td>
					<a data-content='<c:out value="${config.configValue}"/>' data-toggle="popover" tabindex="0" data-trigger="focus" data-placement="bottom">
                  	<script type="text/javascript">
                  		var value = '${fn:replace(fn:replace(config.configValue, newLineChar, " "), newLineChar2, " ")}';
                  		if(value.length > 30)
                  			document.write(value.substring(0, 30) + "...");
                  		else
                  			document.write(value);
                  	</script>
						</a>
               	</td>
               	<td>
					<a data-content='<c:out value="${config.configDesc}"/>' data-toggle="popover" tabindex="0" data-trigger="focus" data-placement="bottom">
                  	<script type="text/javascript">
                  		var value = '${fn:replace(fn:replace(config.configDesc, newLineChar, " "), newLineChar2, " ")}';
                  		if(value.length > 15)
                  			document.write(value.substring(0, 15) + "...");
                  		else
                  			document.write(value);
                  	</script>
						</a>
               	</td>
               	<td>
                  	<c:out value="${config.optUser}"/>
               	</td>
               	<td>
					<fmt:formatDate value="${config.optTime}" pattern="yyyy-MM-dd HH:mm:ss" />
               	</td>
               	<td>
               		<c:if test="${false && project.OWNER_ID == sessionScope.sessionUser.id}">
                  		<a class="deleteConfig" href='/config/delete/<c:out value="${config.configId}"/>?projectId=<c:out value="${projectId}"/>&type=<c:out value="${type}"/>' title="删除"><i class="icon-remove"></i></a>
                  	</c:if>
					<a href='javascript:updateConfig(<c:out value="${config.configId}"/>)' title="更新"><i class="glyphicon glyphicon-edit"></i></a>
					<a href='javascript:history("${config.configId}","${project.DEVELOPMENT_VERSION}")' title="历史记录"><i class="glyphicon glyphicon-leaf"></i></a>
               	</td>
          	</tr>
     	</c:forEach>
	</tbody>
</table>
	<div class="pull-right">
		<jsp:include page="../../layout/_pagination.jsp"></jsp:include>
	</div>
<c:if test="${sessionScope.message != null}">
	<div class="alert alert-danger" role="alert" style="margin-bottom: 5px;width: 400px; padding: 2px 15px 2px 10px;">
		${sessionScope.message}
	</div>
</c:if>

<script type="text/javascript">
$(document).ready(function () {

	$("#preview").click(function(e) {
		window.location.href = '/profile/preview/<c:out value="${project.PROJ_CODE}"/>/<c:out value="${type}"/>?projectId=<c:out value="${projectId}"/>';
	});

	$("#deploy").click(function(e) {
		window.location.href = '/profile/deploy/<c:out value="${project.PROJ_CODE}"/>/<c:out value="${type}"/>?projectId=<c:out value="${projectId}"/>';
	});

	$("a.deleteConfig").click(function(e) {
	    e.preventDefault();
	    bootbox.confirm("确定删除配置项，删除之后不可恢复！", function(confirmed) {
	    	if(confirmed)
	    		window.location.href = $(e.target).parent().attr("href");
	    });

	    return false;
	});

	$("#sel-queryModule").change(function(e) {
		var moduleId = $("#sel-queryModule").val();
		var url = '/profile/<c:out value="${type}"/>/<c:out value="${projectId}"/>';
		if(moduleId)
			url = url + "?moduleId=" + moduleId;

		window.location.href = url;
	});

	$("#queryModule").click(function(e) {
		var moduleId = $("#sel-queryModule").val();
		var url = '/profile/<c:out value="${type}"/>/<c:out value="${projectId}"/>';
		if(moduleId)
			url = url + "?moduleId=" + moduleId;

		window.location.href = url;
	});

	$("#delModule").click(function(e) {
		var moduleId = $("#sel-queryModule").val();
		if(moduleId) {
			window.location.href = '/module/delete/<c:out value="${type}"/>/<c:out value="${projectId}"/>/' + moduleId;
		} else {
			bootbox.alert("请选择一个模块！");
		}
	});

	$("#saveModule").click(function(e) {
		if(!$("#addModuleName").val()) {
			$("#addTip").text("不能为空");
		} else {
			$("#moduleForm")[0].submit();
		}
	});

	/*** 2.Ajax数据预读示例 ***/
// 远程数据源
	var prefetch_provinces = new Bloodhound({
		datumTokenizer: Bloodhound.tokenizers.obj.whitespace('config_key'),
		queryTokenizer: Bloodhound.tokenizers.whitespace,
		// 预获取并缓存
		prefetch: '/profile/json/<c:out value="${projectId}"/>?moduleId=<c:out value="${moduleId}"/>'
	});
	prefetch_provinces.initialize();
	$('#confKey').typeahead(null, {
		name: 'confKey',
		displayKey: 'config_key',
		highlight: true,
		source: prefetch_provinces.ttAdapter()
	});
});
	function show(){
		$('#addConfigWin').modal('toggle');
	}
	function showModule(){
		$('#addModalWin').modal('toggle');
	}
	function togglePage(pageNumber) {
		var moduleId=$("#moduleId").val();
		var confKey=$("#confKey").val();
		var url='/profile/<c:out value="${type}"/>/<c:out value="${projectId}"/>?moduleId='+moduleId+'&confKey='+confKey+'&pageNumber='+pageNumber+'';
		window.location.href=url;
	}
	function doSearch(){
		var confKey=$("#confKey").val();
		var moduleId=$("#moduleId").val();
		var url='/profile/<c:out value="${type}"/>/<c:out value="${projectId}"/>?moduleId='+moduleId+'&confKey='+confKey+'';
		window.location.href=url;
	}
</script>