<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 대리점월정산 > null > 채권사항 메모
-- 작성자 : 정윤수
-- 최초 작성일 : 2022-09-06 11:42:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
		// 행 추가
		function fnAdd() {
				var item = new Object();

				item.org_code = ${orgCode};
				item.seq_no = "";
				item.reg_date = "${inputParam.s_current_dt}";
				item.reg_id = "${inputParam.login_mem_no}";
				item.reg_mem_name = "${SecureUser.kor_name}";
				item.remark = "";
				item.use_yn = "Y";

				AUIGrid.addRow(auiGrid, item, "last");

		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}
			if( !fnCheckGridEmpty(auiGrid) ){
				return;
			}

			var columns = ["seq_no", "org_code", "use_yn", "reg_date", "reg_id", "remark"];
			var gridFrm = fnChangeGridDataToForm(auiGrid, true, columns);
			console.log(gridFrm);
			$M.goNextPageAjaxSave(this_page +"/save", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							location.reload();
						}
					}
			);
		}

		// 그리드 벨리데이션
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["remark"], "내용을 입력하세요.");
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				showStateColumn: true,
				editable : true,
				enableMovingColumn : false,
			};
			var columnLayout = [
				{
					dataField: "seq_no",
					visible : false
				},
				{
					dataField: "use_yn",
					visible : false
				},
				{
					dataField : "reg_id",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText : "작성일",
					dataField : "reg_date",
					dataType : "date",
					width : "15%",
					style : "aui-center",
					formatString : "yyyy-mm-dd",
					editable : false,
				},
				{
					headerText : "작성자",
					dataField : "reg_mem_name",
					width : "15%",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "메모",
					dataField : "remark",
					width : "70%",
					style : "aui-center",
					editable : true,
				},
				{
					width : "50",
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if (event.item.reg_id != "${SecureUser.mem_no}") {
								AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "타인의 메모를 삭제할 수 없습니다.");
								return false;
							};
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved) { // 삭제로우?
								AUIGrid.restoreSoftRows(auiGrid, event.rowIndex);
							} else {
								AUIGrid.removeRow(event.pid, event.rowIndex, event);
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},

			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			// 추가행 에디팅 진입 허용
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				if (event.item.reg_id != "${SecureUser.mem_no}") {
					setTimeout(function() {
						AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "타인의 메모를 수정할 수 없습니다.");
					}, 1);
					return false;
				};
			});
		}

		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->
			<div>
				<div class="title-wrap">
					<h4>${orgName}</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
				<div class="btn-group mt5">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
<!-- /폼테이블-->

        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>