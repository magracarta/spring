<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 장비컨텐츠관리 > null > 항목코드관리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-07-13 14:38
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;

		$(document).ready(function () {
			fnInit();
		});

		function fnInit() {
			createAUIGrid();
			goSearch();
		}

		// 조회
		function goSearch() {
			var param = {};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				editable : true,
				// 수정 표시
				showStateColumn : true
			};

			var columnLayout = [
				{
					dataField : "group_code",
					visible : false
				},
				{
					headerText: "항목코드",
					dataField: "code",
					width : "70",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true,
						allowPoint : false,  // 소수점( . ) 도 허용할지 여부
						// 코드값 벨리데이션 (중복체크, 자리수)
						auiGrid : "#auiGrid",
						minlength : 2,
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText: "항목명",
					dataField: "code_name",
					editable : true,
					style : "aui-left aui-editable"
				},
				{
					headerText: "정렬순서",
					dataField: "sort_no",
					width : "70",
					dataType : "numeric",
					editable : true,
					style : "aui-center aui-editable",
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true, // Input 에서 숫자만 가능케 설정
					}
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width : "70",
					editable : true,
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "70",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
							}
						},
						visibleFunction   :  function(rowIndex, columnIndex, value, item, dataField ) {
							// 삭제버튼은 행 추가시에만 보이게 함
							if(AUIGrid.isAddedById("#auiGrid",item._$uid)) {
								return true;
							}
							else {
								return false;
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});

			// 추가행 에디팅 진입 허용
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				if (event.dataField == "code") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						return false;
					}
				}
			});

			AUIGrid.bind(auiGrid, "addRow", function( event ) {
				fnUpdateCnt();
			});
			AUIGrid.bind(auiGrid, "removeRow", function( event ) {
				fnUpdateCnt();
			});

			fnUpdateCnt();
			$("#auiGrid").resize();
		}

		function fnUpdateCnt() {
			var cnt = AUIGrid.getGridData(auiGrid).length;
			$("#total_cnt").html(cnt);
		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			if (fnCheckGridEmpty(auiGrid) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
						$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);
						goSearch();
					};
				}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 행추가
		function fnAdd() {
			if(fnCheckGridEmpty(auiGrid)) {
				var item = new Object();
				item.group_code = "C_MCH_DATA";
				item.code = "";
				item.code_name = "";
				item.sort_no = null;
				item.use_yn = "Y";
				AUIGrid.addRow(auiGrid, item, 'last');
			}
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["code", "code_name", "sort_no","use_yn"], "필수 항목은 반드시 값을 입력해야합니다.");
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
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap">
					<h4>코드목록</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 380px;"></div>
			</div>
			<!-- /폼테이블-->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
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