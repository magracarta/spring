<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 조직도 > null > 조직도
-- 작성자 : 김상덕
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		});

		function createAUIGrid() {
			var gridPros = {
				rowIdField : "org_code",
// 				height : 955,
				displayTreeOpen : false,
				rowCheckDependingTree : true,
				showRowNumColumn: false,
				enableFilter :true,
				displayTreeOpen : true,
				treeColumnIndex : 1
			};
			var columnLayout = [
				{
					headerText : "조직코드",
					dataField : "org_code",
					width : "20%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "조직",
					dataField : "org_name",
					style : "aui-left aui-link",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					headerText : "조직구분",
					dataField : "org_gubun_name",
					width : "20%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "부서장",
					dataField : "org_mem_name",
					width : "20%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "org_mem_no",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				var openByRowId = AUIGrid.isItemOpenByRowId(event.pid, event.rowIdValue);
				if((event.treeIcon == false && openByRowId == true) || openByRowId == undefined) {
					try {
						// 23.03.07 정윤수 row 클릭할때마다 추가될 수 있도록 추가
						if("${inputParam.multi_yn}" == "Y"){
							if(opener.${inputParam.parent_js_name}(event.item) != undefined) {
								alert(opener.${inputParam.parent_js_name}(event.item));
								return false;
							}
						} else {
							opener.${inputParam.parent_js_name}(event.item);
							window.close();
						}
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					};
				}
			});
			$("#auiGrid").resize();
		}
		function fnClose(){
			window.close();
		}
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div class="btn-group">
					<div class="right">
						<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
						<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
					</div>
				</div>
<!-- 				<div id="auiGrid" style="margin-top: 5px; height: 285px;"></div> -->
				<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>
				<div class="btn-group mt10">
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
					</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>