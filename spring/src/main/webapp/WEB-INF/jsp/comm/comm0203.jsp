<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무 > SMS전송결과 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-10-10 16:35:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>

		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		
		$(document).ready(function() {
			fnInitDate();
			createAUIGrid();
			goSearch();
		});
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_sender_name", "s_receiver_name","s_proc_ypn", "s_sms_send_type_cd"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 시작일자 세팅 현재날짜의 1달 전
		 function fnInitDate() {
			<%--var now = "${inputParam.s_current_dt}";--%>
			// $M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
			 $M.setValue("s_machine_doc_no", "${inputParam.machine_doc_no}");
 		 }
		
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부			
				showRowNumColum : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				editable : false,			
				rowIdField : "_$uid"
			};
			var columnLayout = [
				{
					headerText : "전송요청일시", 
					dataField : "send_date",   
					dataType : "date", 
					width : "120", 	
					formatString : "yy-mm-dd HH:MM:ss",
					style : "aui-center"
				},
				{
					headerText : "전송상태", 
					width : "120", 
					dataField : "proc_ypn_name"
				},
				{
					headerText : "전송일시", 
					dataField : "real_send_date",   
					dataType : "date", 
					width : "120", 	
					formatString : "yy-mm-dd HH:MM:ss",
					style : "aui-center"
				},
				{
					headerText : "구분", 
					dataField : "sms_send_type_name", 
					width : "50", 
					style : "aui-center"				
				},
				{ 
					headerText : "수신자", 
					dataField : "receiver_name",			  
					width : "100"
				},
				{
					headerText : "수신번호", 
					dataField : "phone_no", 
					width : "110", 
					style : "aui-center",
// 					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {					
// 						if(value != ""){
// 							return $M.phoneFormat(value);
// 						}
// 					}	
				},
				{ 
					headerText : "발신자", 
					dataField : "sender_name",
					width : "100", 
					style : "aui-center"	
				},
				{ 
					headerText : "발신번호", 
					dataField : "callback_no",
					width : "110", 
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {					
						if(value != ""){
							return $M.phoneFormat(value);
						}
					}		
				},
				{ 
					headerText : "종류", 
					dataField : "sms_slm_type",
					width : "60", 
					style : "aui-center"
				},
				{ 
					headerText : "전송내용", 
					dataField : "msg",
					width : "370", 
					style : "aui-left"
				},
				{
					dataField : "proc_ypn",
					visible : false
				},
				{
					dataField : "cancel_yn",
					visible : false
				},
				{
					dataField : "sms_send_seq",
 					visible : false
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);		

			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			$("#auiGrid").resize();
			
		}
	
		function goSearch() {
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		function fnSearch(successFunc) {
			isLoading = true;
			var param = {
					s_start_dt : $M.getValue("s_start_dt"),
					s_end_dt : $M.getValue("s_end_dt"),
					s_sms_send_type_cd : $M.getValue("s_sms_send_type_cd"), 		// 전송구분
					s_proc_ypn : $M.getValue("s_proc_ypn"), 						// 전송상태
					s_receiver_name : $M.getValue("s_receiver_name"),				// 수신자
					s_sender_name : $M.getValue("s_sender_name"), 					// 발신자
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
					s_sort_key : "send_date", 
					s_sort_method : "desc",
					"page" : page,
					"rows" : $M.getValue("s_rows"),
					"s_machine_doc_no" : $M.getValue("s_machine_doc_no")
			}
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			); 
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}
		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			         // 제외항목
			         //exceptColumnFields : ["removeBtn"]
			  };
			  fnExportExcel(auiGrid, "SMS전송결과", exportProps);
		}
		
		//예약문자취소
		function goRemove() {
			var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
			
			//예외처리
			if(checkedItems.length <= 0) {
				alert("선택된 데이터가 없습니다.");
				return;
			}
			for(var i=0; i < checkedItems.length; i++) {
				if(checkedItems[i].item.cancel_yn == "N") {
					alert("전송예정시각까지 10분 이상 남지 않은 문자는 취소할 수 없습니다.");
					return;
				}
			}

			var frm = fnCheckedGridDataToForm(auiGrid);
			
			$M.goNextPageAjaxRemove(this_page + "/remove", frm, {method : 'post'},
				function(result) {
					if(result.success) {
						alert('총 '+ result.total_cnt +'건 취소되었습니다.');
						goSearch();
					}
				}
			);
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
			<div class="contents">
	<!-- 기본 -->
				<div class="search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="260px">								
								<col width="50px">
								<col width="90px">		
								<col width="70px">
								<col width="90px">	
								<col width="60px">
								<col width="90px">	
								<col width="60px">
								<col width="60px">
								<!-- 품의서에서 열었을 경우 검색 조건 추가-->
								<c:if test="${not empty inputParam.machine_doc_no}">
									<col width="90px">
									<col width="120px">
								</c:if>
							</colgroup>
							<tbody>
								<tr>
									<th>조회기간</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="조회 시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="조회 완료일" value="${searchDtMap.s_end_dt}" >
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
												<jsp:param name="st_field_name" value="s_start_dt"/>
												<jsp:param name="ed_field_name" value="s_end_dt"/>
												<jsp:param name="click_exec_yn" value="Y"/>
												<jsp:param name="exec_func_name" value="goSearch();"/>
											</jsp:include>
										</div>
									</td>
									<th>전송구분</th>
									<td>
										<select class="form-control" id="s_sms_send_type_cd" name="s_sms_send_type_cd" >
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['SMS_SEND_TYPE']}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>전송상태</th>
									<td>
										<select class="form-control width120px"  id="s_proc_ypn" name="s_proc_ypn"  >
											<option value="" >- 전체 -</option>
											<option value="N" >전송대기</option>
											<option value="P" >전송중</option>
											<option value="E" >전송오류</option>
											<option value="Y" >전송완료</option>
										</select>
									</td>
									<th>수신자</th>
									<td>
										<input type="text" class="form-control" id="s_receiver_name" name="s_receiver_name">
									</td>
									<th>발신자</th>
									<td>
										<input type="text" class="form-control" id="s_sender_name" name="s_sender_name">
									</td>
									<!-- 품의서에서 열었을 경우 검색 조건 추가-->
									<c:if test="${not empty inputParam.machine_doc_no}">
									<th>품의서번호</th>
									<td>
										<input type="text" class="form-control" id="s_machine_doc_no" name="s_machine_doc_no">
									</td>
									</c:if>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch();" >조회</button>
									</td>
								</tr>
								</tbody>
						</table>
					</div>
	<!-- /기본 -->
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="left" style="margin-left:50px;">
							<span style="color: #ff7f00;">※ SMS전송결과는 통신사 사정에 의해 반영이 늦을수 있습니다.</span>
							<br><span style="color: #ff7f00;">※ 예약문자 취소는 전송예정시각까지 10분 이상 남은 것만 가능합니다.</span>
						</div>
						<div class="right">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
							</c:if>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" style="height:555px; margin-top: 5px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
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