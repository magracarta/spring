<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 조직도(메인) > null > 조직도(메인)
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-10-24 14:45:27
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
				rowIdField : "name",
				rowCheckDependingTree : true,
				showRowNumColumn: false,
				enableFilter :true,
				displayTreeOpen : true,
				treeColumnIndex : 0
			};
			var columnLayout = [
				{
					headerText : "조직",
					dataField : "name",
					width : "15%",
					style : "aui-left",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					dataField : "mem_no",
					visible : false
				},
				{
					headerText : "부서",
					dataField : "org_name",
					width : "9%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText : "직책",
					dataField : "grade_name",
					width : "6%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				// {
				// 	headerText : "직급",
				// 	dataField : "job_name",
				// 	width : "6%",
				// 	style : "aui-center",
				// 	editable : false,
				// 	filter : {
				// 		showIcon : true
				// 	}
				// },
				{
					headerText : "휴무",
					dataField : "holiday_type_name",
					width : "6%",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (item.holiday_type_name == "" || item.holiday_type_name == null || item.holiday_type_name == undefined) {
							ret = "근무";
						}
					    return ret;
					},
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "holiday_type_cd",
					visible : false
				},
				{
					headerText : "사무실번호",
					dataField : "office_tel_no",
					width : "8%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "FAX",
					dataField : "office_fax_no",
					width : "8%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "휴대폰",
					dataField : "hp_no",
					width : "10%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = value;
						if($M.nvl(value, "") != ""){
							template = '<div>' + value +'<button type="button" class="icon-btn-search" onclick="javascript:fnOpenSms(\'' + item.name + '\',\'' + item.hp_origin + '\');" style="float: right;"> <i class="material-iconsforum"> </i></button></div>';
						}
						return template;
					}
				},
				// 2024-04-12 (Q&A : 22324) 조직도 부품/렌탈란 삭제 요청
				// {
				// 	headerText : "부품/렌탈",
				// 	dataField : "part_tel_no",
				// 	width : "8%",
				// 	style : "aui-center",
				// 	editable : false,
				// 	filter : {
				// 		showIcon : true
				// 	}
				// },
				{
					headerText : "서비스",
					dataField : "service_tel_no",
					width : "8%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "사무실",
					dataField : "office_full_addr",
// 					width : "20%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "hp_origin",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellClick", function(event){
// 				var openByRowId = AUIGrid.isItemOpenByRowId(event.pid, event.rowIdValue);
// 				if((event.treeIcon == false && openByRowId == true) || openByRowId == undefined) {
// 					try {
// 						opener.${inputParam.parent_js_name}(event.item);
// 						window.close();
// 					} catch(e) {
// 						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
// 					};
// 				}
			});
			$("#auiGrid").resize();
		}

		function fnOpenSms(custName, phoneNum) {
			var param = {
				  name : custName,
				  hp_no : phoneNum
			}
			openSendSmsPanel($M.toGetParam(param));
		}

		// 마스킹 체크시 조회
		function goSearch() {
			var param = {
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
					, "s_agency_exclude_yn" : $M.getValue("s_agency_exclude_yn") == "Y" ? "Y" : "N"
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success){
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "조직도", exportProps);
		}
	</script>
</head>
<body class="bg-white">
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
						<div class="form-check form-check-inline">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" onchange="javascript:goSearch()">
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</c:if>
							&nbsp;&nbsp;
							<input class="form-check-input" type="checkbox" id="s_agency_exclude_yn" name="s_agency_exclude_yn" checked="checked" value="Y" onchange="javascript:goSearch()"/>
							<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
							<%--<label class="form-check-input" for="s_agency_exclude_yn">대리점제외</label>--%>
							<label class="form-check-input" for="s_agency_exclude_yn">위탁판매점제외</label>
						</div>
						<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
						<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
						<button type="button" onclick="javascript:fnDownloadExcel();"; class="btn btn-default"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
					</div>
				</div>
<!-- 				<div id="auiGrid" style="margin-top: 5px; height: 285px;"></div> -->
				<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>
