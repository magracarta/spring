<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 결재화면프로세스
-- 작성자 : 손광진
-- 최초 작성일 : 2020-02-06 11:16:59
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		// 호출한 쪽에서 받아온 job_cd
		var getApprJobCode = "${inputParam.s_appr_job_cd}";
		
		$(document).ready(function() {
			console.log(listJson);
			// goSearch(getApprJobCode);
			createAUIGrid();
		});
		
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowNumber show
				showRowNumColumn : true,
				fillColumnSizeMode : false,
			};
			var columnLayout = [
				{
					headerText : "최근사용일", 
					dataField : "appr_last_date", 
					width : "15%", 
					style : "aui-center"
				},
				{
					headerText : "결재라인명", 
					dataField : "appr_line_name", 
					width : "15%", 
					style : "aui-left"
				},
				{
					headerText : "결재라인 직원명", 
					dataField : "appr_mem_name_line", 
					width : "25%", 
					style : "aui-left"
				},
				{
					headerText : "결재상태", 
					dataField : "appr_line_seq", 
					width : "10%",
					colSpan : 2,
					renderer : {
						type : "ButtonRenderer",
						labelText : "적용",
						onClick : function(event) {
							goApprLineSave(event.item.appr_mem_no_line);
						},
					},
					style : "aui-center",
					editable : false
				},
				{
					dataField : "appr_line_seq", 
					width : "10%", 
					renderer : {
						type : "ButtonRenderer",
						labelText : "삭제",
						onClick : function(event) {
							goApprLineDelete(event.item.appr_mem_no_line);
						},
						visibleFunction :  function(rowIndex, columnIndex, value, item, dataField ) {
							// 행 아이템의 name 이 0이면 버튼 표시 하지 않음
					       if(item.appr_line_seq != "0") {
					              return false;
					        }
					        return true;
						}
					},
					style : "aui-center",
					editable : false
				}
			]
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 데이터 세팅
			AUIGrid.setGridData(auiGrid, listJson);
			$("#auiGrid").resize();
		}
		
		function goApprLineDelete(memNo) {
			var apprNumLine = memNo;	// 받아온 회원 라인번호
			var param = {
				"appr_mem_no_line"	: apprNumLine
			};
			$M.goNextPageAjaxRemove(this_page + "/" + getApprJobCode + "/remove", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						self.location.reload();
					};
				}
			);
		}
		
		function goApprLineSave(memNo) {
			var apprNumLine = memNo;	// 받아온 회원 라인번호
			var param = {
				"appr_mem_no_line"	: apprNumLine
			};
			// var saveApprLine = ""; // opener로 보내줄 list 데이터
			$M.goNextPageAjax(this_page + "/" + getApprJobCode + "/getApprLine", $M.toGetParam(param), { method : "GET"},
				function(apprList) {
					if(apprList.success) {
						try {
							var saveApprLine = apprList;
							window.close();	
							opener.${inputParam.parent_js_name}(saveApprLine);
						} catch(e) {
							alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
						}
					};
				}
			);
			
		}
		
		//팝업 끄기
		function fnClose() {
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
            <h2>결재관리</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->			
			<div id="auiGrid" style="margin-top: 5px; height: 420px;"></div>					
<!-- /폼테이블 -->
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