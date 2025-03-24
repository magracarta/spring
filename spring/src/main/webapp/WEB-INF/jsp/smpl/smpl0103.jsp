<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var auiGrid;
		
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();		
		});
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "last_mem_appr_seq",
				showRowNumColumn: false
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "결재번호",
				    dataField: "last_mem_appr_seq",
					width : "5%",
					style : "aui-center"
				},
				{
					headerText : "결재업무",
					dataField : "appr_job_name",
					width: "5%",
					style : "aui-center"
				},
				{
				    headerText: "결재라인 직원명",
				    dataField: "path_appr_mem_name",
					width : "15%",
					style : "aui-left"
				},
				{
				    headerText: "결재라인 직원코드",
				    dataField: "path_appr_mem_no",
					width : "20%",
					style : "aui-left"
				},
				{
				    headerText: "결재라인 Web_id",
				    dataField: "path_appr_web_id",
					width : "20%",
					style : "aui-left"
				},
				{
				    headerText: "결재상태 라인",
				    dataField: "path_appr_status_name",
					width : "15%",
					style : "aui-left"
				},
				{
				    headerText: "최종결재상태",
				    dataField: "appr_proc_status_name",
					width : "10%",
					style : "aui-center"
				},

				{
					headerText : "등록일시",
					dataField : "reg_date",
					width: "10%",
					style : "aui-center"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 클릭한 셀 데이터 받음
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var param = {
						seq 			: event.item["last_mem_appr_seq"]
					};
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=300, left=0, top=0";
				$M.goNextPage("/smpl/smpl0103/" + param.seq, "pop_check_yn=N", {popupStatus : poppupOption});

			});
			
			function fnResultApproval(row) {
				alert(row);
				return false;
			}
		}
		
		// 직원 조회
		function goSearch() {
			var param = {
				"s_appr_job_cd" : $M.getValue("s_appr_job_cd"),
				"s_appr_proc_status_cd" : $M.getValue("s_appr_proc_status_cd")
			};
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}
		
		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_appr_job_cd", "s_appr_proc_status_cd"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        	<!-- <h2>직원조회</h2> -->
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	  
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="130px">
						<col width="60px">
						<col width="90px">
						<col width="60px">
						<col width="130px">
					</colgroup>
					<tbody>
						<tr>
							<th>결재업무</th>
							<td>
								<select id="s_appr_job_cd" name="s_appr_job_cd" class="form-control">
									<option value="">전체</option>
										<c:forEach var="list" items="${codeMap['APPR_JOB']}">
										  <option value="${list.code_value}">${list.code_name}</option>
										</c:forEach>
								</select>
							</td>
							<th>결재업무</th>
							<td>
								<select id="s_appr_proc_status_cd" name="s_appr_proc_status_cd" class="form-control">
									<option value="">전체</option>
										<c:forEach var="list" items="${codeMap['APPR_PROC_STATUS']}">
										  <option value="${list.code_value}">${list.code_name}</option>
										</c:forEach>
								</select>
							</td>
							
							<td class=""><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch();">조회</button></td>							
						</tr>						
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			<!-- 그리드 생성 -->
			<div id="auiGrid" style="margin-top: 5px; height: 400px"></div>
			<!-- 버튼영역 -->
			<div class="btn-group mt5">
				<div class="left">				
					총 <strong class="text-primary" id="total_cnt">0</strong>건 
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- 버튼영역 -->
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>