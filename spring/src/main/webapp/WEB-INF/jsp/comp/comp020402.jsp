<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 문자발송 > null > 견본문자
-- 작성자 : 박예진
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
		
		// 조회
		function goSearch() {
			var param = {
				"s_msg" : $M.getValue("s_msg"),
				"s_reg_mem_name" : $M.getValue("s_reg_mem_name"),
				"comm_yn" : "Y",
				"s_sort_key" : "reg_date",
				"s_sort_method" : "desc"
			};
			$M.goNextPageAjax("/comp/comp0204/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		function enter(fieldObj) {
			var field = [ "s_reg_mem_name", "s_msg" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 수정
		function goModify() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert(msg.alert.data.noChanged);
				return false;
			};
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxModify("/comp/comp0204/modify", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "sms_sample_seq",
				showRowNumColumn: true,
				showSelectionBorder : false
			};
			var columnLayout = [
				{
					dataField : "sms_sample_seq",
					visible : false
				},
				{
					headerText : "등록일", 
					dataField : "sms_reg_date",
					dataType : "date",
					formatString : "yyyy-mm-dd", 
					width : "12%",
					style : "aui-center"
				},
				{
					headerText : "등록자", 
					dataField : "reg_mem_name",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "내용", 
					dataField : "msg",
					style : "aui-left"
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "8%", 
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(String(this.tagName).toUpperCase() == "INPUT") return;
				if(event.dataField != "use_yn") {
					// Row행 클릭 시 반영
					try{
						top.${inputParam.parent_js_name}(event.item);
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
				} else {
					if(event.value == "Y") {
						AUIGrid.setCellValue(event.pid, event.rowIndex, "use_yn", "N");
					} 
					if(event.value == "N") {
						AUIGrid.setCellValue(event.pid, event.rowIndex, "use_yn", "Y");
					}
				} 
			});
		}

		
		//팝업 끄기
		function fnClose() {
			top.fnClose();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <div class="content-wrap-sms">
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="50px">
						<col width="100px">
						<col width="50px">
						<col width="140px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>등록자</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_reg_mem_name" name="s_reg_mem_name">
								</div>
							</td>
							<th>내용</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_msg" name="s_msg">
								</div>
							</td>
							<td class=""><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
		<div class="title-wrap mt10">
				<h4>공통견본문자내역</h4>
			</div>
<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top:5px;width: 100%; height: 260px;"></div>
			<div class="btn-group mt5">	
				<div class="left">	
					총 <strong class="text-primary" id="total_cnt">0</strong>건</div>
				<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>