<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > MBO > null
-- 작성자 : 정재호
-- 최초 작성일 : 2023-12-12 00:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var rowIndex;
		$(document).ready(function () {
			createAUIGrid();
		});
		
		// 저장 버튼
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return;
			}

			var frm = fnChangeGridDataToForm(auiGrid);

			$M.goNextPageAjaxSave(this_page + "/save", frm , {method : 'POST'},
				function(result) {
					if(result.success) {
						window.location.reload();
					}
				}
			);
		}
		
		// 파일 업로드 팝업 열기
		function openFileUpload(event) {
  			rowIndex = event.rowIndex;
			var param = {
				upload_type : 'MBO',
				file_type : 'xlsx',
			}
			
			openFileUploadPanel("callBackFileUpload", $M.toGetParam(param));
		}
		
		// 파일 업로드 콜백
		function callBackFileUpload(file) {
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
			AUIGrid.updateRow(auiGrid, { ...item, "file_name" : file.file_name, "file_seq" : file.file_seq }, rowIndex);
		}

		// 센터별 지출/실적 팝업 클릭
		function goCenterAvgAmtPopup() {
			var param = {
				"s_year": ${s_year},
			}

			var poppupOption = "";
			$M.goNextPage('/serv/serv050202p01', $M.toGetParam(param), {popupStatus: poppupOption});
		}

		// 그리드 셋팅
		function createAUIGrid() {
			var gridPros = {
				editable: false,
				rowIdField: "_$uid",
				showRowNumColumn: false,
			};

			var columnLayout = [
				{
					headerText: "연도",
					dataField: "mbo_year",
					width : "100",
					minWidth : "65",
				},
				{
					headerText: "파일명",
					dataField: "file_name",
					width : "300",
					minWidth : "65",
					style: 'aui-popup text-left'
				},
				{
					headerText : "관리",
					dataField : "upload",
					width : "65",
					minWidth : "65",
					renderer : {
						type : "ButtonRenderer",
						onClick : openFileUpload,
					},
					labelFunction : function(rowIndex, rowIndex, value,headerText, item) {
						return "관리";
					}
				},
				{
					dataField: "file_seq",
					visible : false,
					editable : false
				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();

			// mbo 파일등록 권한 없으면 '관리' 컬럼 숨김
			if(${page.fnc.F05303_001 ne 'Y'}){
				AUIGrid.hideColumnByDataField(auiGrid, ["upload"]); // 숨길대상
			}

			// 셀 클릭 이벤트
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "file_name") {
					if(event?.item?.file_seq) {
						fileDownload(event.item.file_seq);
					}
				}
			});
		}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="">
				<div class="">
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>MBO 관리</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 490px; width:100%;"></div>

					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
								<jsp:param name="pos" value="BOM_R"/>
							</jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>