<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 부서권한관리 > null > 부서권한관리 팝업
-- 작성자 : 정선경
-- 최초 작성일 : 2022-12-07 15:02:43
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var upOrgList = ${upOrgList};

		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "org_code",
				headerHeight : 20,
				showRowNumColumn : true,
				editable : true,
				fillColumnSizeMode : false,
				showStateColumn:true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "상위조직",
					dataField : "up_org_code",
					width: "35%",
					style : "aui-left aui-editable",
					required : true,
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : true,
						required : true,
						editable : true,
						list : upOrgList,
						listAlign : "left",
						keyField : "org_code",
						valueField  : "org_name"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var retStr = value;
						for(var i = 0; i < upOrgList.length; i++) {
							if (value == upOrgList[i].org_code) {
								retStr = upOrgList[i].org_name;
							} else if (value == null || value == "") {
								retStr = "- 선택 -";
							}
						}
						return retStr;
					}
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText : "부서권한명",
					dataField : "org_kor_name",
					required : true,
					style : "aui-left aui-editable"
				},
				{
					headerText : "순번",
					dataField : "sort_no",
					width: "12%",
					style : "aui-center aui-editable",
					required : true
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width: "12%",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				},
				{
					dataField : "cmd",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
		}

		// 권한목록 조회
		function goSearch() {
			var param = {
				"s_sort_key" : "sort_no || path_org_name || org_name",
				"s_sort_method" : "asc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result.list);
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}

		// 부서권한 행추가
		function fnAdd() {
			var item = new Object();
			item.cmd = "C";
			item.up_org_code = "";
			item.org_name = "";
			item.sort_no = 1;
			item.use_yn = "Y";
			AUIGrid.addRow(auiGrid, item, "last");
		}

		// 부서권한 저장
		function goSave() {
	    	if(fnChangeGridDataCnt(auiGrid) == 0) {
    			alert("변경된 데이터가 없습니다.");
    			return false;
	    	}
			if(!AUIGrid.validation(auiGrid)) {
				return false;
			}

			var frm = $M.toValueForm(document.main_form);
			var gridFrm = fnChangeGridDataToForm(auiGrid);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxSave(this_page + '/save', gridFrm , {method : 'POST'},
				function(result) {
					if(result.success) {
						window.opener.goSearch();
						fnClose();
					}
				}
			);
		}

		// 팝업 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 전체 영역 -->
<div class="popup-wrap width-100per">
	<!-- 메인 타이틀 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /메인 타이틀 -->
	<div class="content-wrap">

		<div>
			<div class="title-wrap">
				<h4>권한목록</h4>
				<div class="right mt5" style="text-align: right;">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<!-- 그리드 생성 -->
			<div id="auiGrid" style="margin-top: 5px;"></div>
		</div>
		<!-- 버튼영역 -->
		<div class="btn-group mt5">
			<div class="left">
				총 <strong class="text-primary" id="total_cnt">0</strong>건
			</div>
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
		<!-- /버튼영역 -->
	</div>
</div>
	<!-- /contents 전체 영역 -->	
</form>
</body>
</html>