<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 new > 상세 > 공구함관리
-- 작성자 : jsk
-- 최초 작성일 : 2024-05-27 13:20:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var auiGridDtl;
		var dtlRowCnt = 0;

		var svcToolBoxList = JSON.parse('${codeMapJsonObj['SVC_TOOL_BOX']}');
		var centerList = ${orgCenterListJson};

		$(document).ready(function() {
			createAUIGrid();
			createAUIGridDtl();
			goSearch();
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				fillColumnSizeMode: true,
				editable : false
			};
			var columnLayout = [
				{
					dataField : "center_org_code",
					visible : false
				},
				{
					headerText : "센터",
					dataField : "center_org_name",
					style : "aui-center",
					width : "13%",
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						if (${center_auth_yn eq 'Y'}) {
							return "aui-popup";
						} else {
							return "";
						}
					},
				}
			];

			var addColumnObjList = [];
			// 공구함종류 추가
			for (var i = 0; i < svcToolBoxList.length; ++i) {
				var result = svcToolBoxList[i];
				var boxColumnObj = {
					headerText : result.code_name,
					dataField : "box" + result.code_value + "_cnt",
					style : "aui-center",
					width : "11%",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var retStr = "";
						if (value != null && value > 0) {
							retStr = AUIGrid.formatNumber(value, "#,##0");
						} else {
							retStr = "X";
						}
						return retStr;
					}
				}
				addColumnObjList.push(boxColumnObj);
			}
			addColumnObjList.push(
					{
						headerText : "변경자",
						dataField : "last_upt_mem_name",
						style : "aui-center",
						width : "15%"
					},
					{
						headerText : "변경일",
						dataField : "last_upt_date",
						dataType : "date",
						formatString : "yyyy-mm-dd",
						style : "aui-center",
						width : "15%"
					}
			);

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.addColumn(auiGrid, addColumnObjList, 'last');
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(${center_auth_yn eq 'Y'} && event.dataField == "center_org_name") {
					$M.setValue("center_org_code", event.item.center_org_code);
					goSearchDtl();
				}
			});

			$("#auiGrid").resize();
		}

		// 공구함 그리드생성
		function createAUIGridDtl() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true
			};
			var columnLayout = [
				{
					dataField : "center_org_code",
					visible : false
				},
				{
					dataField : "nsvc_tool_box_seq",
					visible : false
				},
				{
					headerText : "공구함명칭",
					dataField : "box_name",
					style : "aui-left",
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 30,
						validator : AUIGrid.commonValidator
					},
					width : "20%"
				},
				{
					headerText : "공구함종류",
					dataField : "svc_tool_box_cd",
					width : "15%",
					style : "aui-center",
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : true,
						required : true,
						editable : true,
						list : svcToolBoxList,
						listAlign : "left",
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var retStr = value;
						for(var i = 0; i < svcToolBoxList.length; i++) {
							if (value == svcToolBoxList[i].code_value) {
								retStr = svcToolBoxList[i].code_name;
							} else if (value == null || value == "") {
								retStr = "";
							}
						}
						return retStr;
					}
				},
				{
					headerText : "비고",
					dataField : "remark",
					style : "aui-left",
					width : "40%",
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 100,
						validator : AUIGrid.commonValidator
					},
					style : "aui-left",
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width : "10%",
					style : "aui-center aui-editable",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				}
			];
			auiGridDtl = AUIGrid.create("#auiGridDtl", columnLayout, gridPros);
			AUIGrid.bind(auiGridDtl, "cellClick", auiCellEditHandler);
			AUIGrid.setGridData(auiGridDtl,[]);

			$("#auiGridDtl").resize();
		}

		function auiCellEditHandler(event) {
			switch(event.type) {
				case "cellClick" :
					if(event.dataField == "use_yn" && event.value == "N") {
						var param = {
							"nsvc_tool_box_seq": event.item.nsvc_tool_box_seq
						}
						$M.goNextPageAjax(this_page + "/toolBoxChkCount", $M.toGetParam(param), {method: "GET"},
								function (result) {
									if (result.success) {
										if (result.check_exist_yn == "Y") {
											alert("이전 실사내역이 있어 공구함 삭제 불가합니다.");
										} else {
											AUIGrid.setCellValue(event.pid, event.rowIndex, "use_yn", "N");
										}
									}
								}
						);
					}
					break;
			}
		}

		// 전센터 공구함현황 조회
		function goSearch() {
			$M.goNextPageAjax(this_page + "/search", {}, {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							goSearchDtl();
						}
					}
			);
		}

		// 센터별 공구함목록 조회
		function goSearchDtl() {
			var param = {
				"center_org_code": $M.getValue("center_org_code")
			};
			$M.goNextPageAjax(this_page + "/searchDtl", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGridDtl, result.list);
							dtlRowCnt = result.list.length;

							var centerOrgName = getCenterOrgCode();
							$("#span_org_name").html(centerOrgName);
						}
					}
			);
		}

		// 공구함 행추가
		function fnAdd() {
			if ($M.getValue("center_org_code") == "") {
				alert("센터를 선택해주세요");
				return false;
			}
			if (fnCheckGridEmpty(auiGridDtl)) {
				var item = new Object();
				item.nsvc_tool_box_seq = 0;
				item.center_org_code = $M.getValue("center_org_code");
				item.box_name = "공구함" + (dtlRowCnt + 1);
				item.svc_tool_box_cd = "";
				item.remark = "";
				item.use_yn = "Y";

				AUIGrid.addRow(auiGridDtl, item, 'last');
				dtlRowCnt++;
			}
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGridDtl, ["box_name", "svc_tool_box_cd"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGridDtl) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			var gridData = fnChangeGridDataToForm(auiGridDtl);
			$M.goNextPageAjaxSave(this_page + "/save", gridData, {method : 'POST'},
					function(result) {
						if(result.success) {
							opener.${inputParam.parent_js_name}();
							goSearch();
						}
					}
			);
		}

		// 센터명 세팅
		function getCenterOrgCode() {
			var centerOrgName = "";
			var centerOrgCode = $M.getValue("center_org_code");
			for (i = 0; i<centerList.length; i++) {
				if (centerList[i].org_code == centerOrgCode) {
					centerOrgName = centerList[i].org_name;
					break;
				}
			}
			return centerOrgName;
		}

		// 닫기
		function fnClose() {
			opener.${inputParam.parent_js_name}();
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="center_org_code" 	name="center_org_code" value="${inputParam.center_org_code}" />

	<!-- 팝업 -->
    <div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
		<!-- /타이틀영역 -->
        <div class="content-wrap">
			<!-- 폼테이블1 -->
			<div>
				<!-- 전 센터 공구함 현황 -->
				<div class="title-wrap">
					<h4>전 센터 공구함 현황</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
				<!-- /전 센터 공구함 현황 -->
			</div>
			<!-- /폼테이블1 -->

			<!-- 폼테이블2 -->
			<div>
				<!-- 공구함 -->
				<div class="title-wrap mt10">
					<div class="left">
						<h4><span class="text-primary" id="span_org_name" name="span_org_name">${center_org_name}</span> 공구함</h4>
					</div>
					<div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGridDtl" style="margin-top: 5px; height: 324px;"></div>
				<!-- /공구함 -->
			</div>
			<!-- /폼테이블2 -->

			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>