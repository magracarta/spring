<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 직원연관팝업 > 직원연관팝업 > null > 직원조회(조직도)
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-17 11:41:06
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
			if('${inputParam.multi_yn}' == 'N') {
				if($(".btn-info").html() == '적용') {
					$("#btnHide").children().eq(0).attr('id','btnApply');
					$("#btnApply").css({
						display: "none"
					});
				}
			}
		});

		// 닫기
		function fnClose() {
			window.close();
		}

		//적용
		function goApply() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			console.log(itemArr);
			opener.${inputParam.parent_js_name}(itemArr);
			window.close();
		}

		function setMemberOrgMapPanel(row) {
			alert(JSON.stringify(row));
		}

		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			if('${inputParam.multi_yn}' == 'Y') {
				var gridPros = {
					rowIdField : "name",
					enableFilter :true,
					// 엑스트라 체크박스 출력 여부
					showRowCheckColumn : true,
					// 전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
					// rowNumber
					showRowNumColumn: false,
					// 부모-자식 간의 관계에 따라 체크박스를 표현
					rowCheckDependingTree : true,
					displayTreeOpen : true,
					treeColumnIndex : 0,
					// 전체선택 제어 컨트롤
					independentAllCheckBox: true,
				};
			} else {
				var gridPros = {
					rowIdField : "name",
					rowCheckDependingTree : true,
					showRowNumColumn: false,
					displayTreeOpen : true,
					treeColumnIndex : 0,
					enableFilter :true,
					independentAllCheckBox: true,
				};
			}

			var columnLayout = [
				{
					headerText : "조직",
					dataField : "name",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					headerText : "직책",
					dataField : "grade_name",
					width : "20%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "휴대폰",
					dataField : "hp_no",
					width : "25%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if('${inputParam.multi_yn}' == 'N') {
					var openByRowId = AUIGrid.isItemOpenByRowId(event.pid, event.rowIdValue);
					if((event.treeIcon == false && openByRowId == true) || openByRowId == undefined) {
						try {
							opener.${inputParam.parent_js_name}(event.item);
							window.close();
						} catch(e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						};
					}
				} else {
					// 다중선택시 셀클릭 이벤트 바인딩
					AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
				}
			});
			// [14313] 쪽지함 필터 개선 - 작성자: 김경빈
			// 전체 선택 이벤트 바인딩 커스텀
			extraAllCheckAtTreeGrid(auiGrid, 'YK건기');
			$("#auiGrid").resize();
		}

		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			var item = event.item, rowIdField, rowId;
			rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
			rowId = item[rowIdField];
			// 이미 체크 선택되었는지 검사
			if(AUIGrid.isCheckedRowById(event.pid, rowId)) {
				// 엑스트라 체크박스 체크해제 추가
				AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
			} else {
				// 엑스트라 체크박스 체크 추가
				AUIGrid.addCheckedRowsByIds(event.pid, rowId);
			}
		};
		
		// 마스킹 체크시 조회
		function goSearch() {
			var param = {
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success){
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			); 
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
					<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
					<div class="form-check form-check-inline">
						<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" onchange="javascript:goSearch()">
						<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
					</div>
					</c:if>
					<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
					<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
				</div>
			</div>
			<!-- 				<div id="auiGrid" style="margin-top: 5px; height: 285px;"></div> -->
			<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>
			<div class="btn-group mt10">
				<div class="right" id="btnHide">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>