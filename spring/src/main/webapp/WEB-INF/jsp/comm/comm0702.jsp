<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 회계 > 입금대체계정코드관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-05-07 17:00:47
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	$(document).ready(function() {
			createAUIGrid();
		});
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validation(auiGrid);
		}

		// 입금대체계정 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			
			if (fnCheckGridEmpty(auiGrid) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			};
			
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : "POST"}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			); 
		}
		
		// 입금대체 계정관리 행 추가
		function fnAdd() {
			if(fnCheckGridEmpty(auiGrid)) {
				goAccountListPopup();	
			};
		}
		
		// 계정관리 목록 팝업호출
		function goAccountListPopup() {
			var param = {};
			param.parent_js_name = "fnSetAccountInfo";
			var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=550, height=480, left=0, top=0";
			$M.goNextPage("/acnt/acnt0101p03", $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 계정과목 결과
		function fnSetAccountInfo(data) {
			console.log(data.acnt_code);
			if($M.nvl(data.acnt_code, "") == "") {
				return;
			};
			// 새로 추가한 데이터가 기존그리드에 있을 시 삭제
			var rowItems = AUIGrid.getItemsByValue(auiGrid, "acnt_code", data.acnt_code);
			
			if(rowItems.length > 0 ) {
				alert("계정과목이 중복되었습니다.");
				return;
			} else {
	    		var item = new Object();
	    		item.acnt_code = "";
	    		item.acnt_name = "";
	    		item.deposit_replace_acnt_yn = "Y";
	    		item.deposit_replace_acnt_use_yn = "Y";
				AUIGrid.addRow(auiGrid, item, "first");
			    AUIGrid.updateRow(auiGrid, { "acnt_code" : data.acnt_code }, 0);
			    AUIGrid.updateRow(auiGrid, { "acnt_name" : data.acnt_name }, 0);
			};
		}
		
		function fnUpdateCnt() {
			var cnt = AUIGrid.getGridData(auiGrid).length;
			$("#total_cnt").html(cnt);
		}
	
		function createAUIGrid() {
			var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true
			};
			var columnLayout = [
				{
	
					headerText : "계정코드", 
					dataField : "acnt_code", 
					width : "25%", 
					style : "aui-center",
					editable : false,
					required : true,
				}, 
				{
					headerText : "계정과목명",
					dataField : "acnt_name", 
					width : "50%",
					style : "aui-center",
					editable : false,
					required : true,
				},
				{
					headerText : "사용여부", 
					dataField : "deposit_replace_acnt_use_yn", 
					width : "25%", 
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				},			
				{ 
					dataField : "deposit_replace_acnt_yn", 
					width : "15%", 
					style : "aui-center",
					visible : false
				}			
			]
	
			// 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, listJson);
			$("#total_cnt_bank_deal").html(listJson.total_cnt);
			
			AUIGrid.bind(auiGrid, "addRow", function( event ) {
				fnUpdateCnt();
			});
			AUIGrid.bind(auiGrid, "removeRow", function( event ) {
				fnUpdateCnt();
			});
		}

	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<div class="layout-box">
		<!-- contents 전체 영역 -->
			<div class="content-wrap">
				<div class="content-box">
			<!-- 메인 타이틀 -->
					<div class="main-title">
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
			<!-- /메인 타이틀 -->
					<div class="contents"  style="width : 30%;">	
			<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="title-wrap mt10">
							<div class="btn-group">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->					
						<div id="auiGrid" style="margin-top: 5px; height: 480px;"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
							</div>						
							<div class="right">					
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
				</div>	
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
			</div>
		<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>