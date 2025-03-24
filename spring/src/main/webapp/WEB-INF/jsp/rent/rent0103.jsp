<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 고객 앱 신청현황 > null > null
-- 작성자 : 이강원
-- 최초 작성일 : 2023-08-04 15:06:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});

		// 조회
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
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {
				return;
			};
			isLoading = true;
			var param = {
				s_cust_name : $M.getValue("s_cust_name"),
				s_org_code : $M.getValue("s_org_code"),
				s_hp_no : $M.getValue("s_hp_no"),
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_complete_yn : $M.getValue("s_complete_yn"),
				s_extend_yn : $M.getValue("s_extend_yn"),
				s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				page : page,
				rows : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			)
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
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				enableFilter :true,
				rowIdField : "c_rental_request_seq",
				rowIdTrustMode : true,
				showRowNumColumn: true
			};
			var columnLayout = [
				{
					headerText : "신청일자",
					dataField : "request_dt",
					dataType : "date",
					width : "80",
					minWidth : "80",
					formatString : "yy-mm-dd",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "구분",
					dataField : "rental_gubun",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "120",
					minWidth : "120",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "휴대폰",
					dataField : "hp_no",
					width : "120",
					minWidth : "120",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "90",
					minWidth : "90",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "120",
					minWidth : "120",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈신청기간",
					dataField : "rental_dt",
					width : "200",
					minWidth : "200",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "연장신청기간",
					dataField : "extend_dt",
					width : "200",
					minWidth : "200",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "일정구분",
					dataField : "fix_day_yn",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "실 사용지역",
					dataField : "addr",
					width : "200",
					minWidth : "200",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "배송요청",
					dataField : "delivery_rnt_req_name",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "센터",
					dataField : "org_name",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "처리상태",
					dataField : "complete_yn",
					width : "70",
					minWidth : "70",
					style : "aui-center aui-link",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "처리일자",
					dataField : "complete_dt",
					dataType : "date",
					width : "80",
					minWidth : "80",
					formatString : "yy-mm-dd",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "처리자",
					dataField : "complete_mem_name",
					width : "100",
					minWidth : "100",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "참조문서번호",
					dataField : "rental_doc_no",
					width : "120",
					minWidth : "120",
					style : "aui-center aui-link",
				},
				{
					dataField : "extend_yn",
					visible : false
				},
				{
					dataField : "c_rental_request_seq",
					visible : false
				},
				{
					dataField : "doc_type",
					visible : false
				},
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGrid, 9);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
			
			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//차대번호셀 선택한 경우 
				if (event.dataField == "complete_yn") {
					var params = {
						c_rental_request_seq: event.item.c_rental_request_seq
					};
					var popupOption = "";
					$M.goNextPage('/rent/rent0103p01', $M.toGetParam(params), {popupStatus: popupOption});
				} else if(event.dataField == "rental_doc_no") {
					if(event.value == "") {
						return;
					}

					var params = {
						rental_doc_no : event.item.rental_doc_no
					}

					var popupOption = "";
					// 연장문서인 경우
					if(event.item.doc_type == "E") {
						popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
						$M.goNextPage('/rent/rent0102p02', $M.toGetParam(params), {popupStatus : popupOption});
					} else if(event.item.doc_type =="O") {
						// 매출처리까지 끝난 연장이 아닌 문서인 경우
						popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
						$M.goNextPage('/rent/rent0102p01', $M.toGetParam(params), {popupStatus : popupOption});
					} else {
						popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
						$M.goNextPage('/rent/rent0101p01', $M.toGetParam(params), {popupStatus : popupOption});
					}
				}
			});
		}

		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_hp_no", "s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "고객 앱 신청현황", exportProps);
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
					<table class="table">
						<colgroup>
							<col width="50px">
							<col width="280px">
							<col width="50px">
							<col width="90px">
							<col width="50px">
							<col width="90px">	
							<col width="50px">
							<col width="100px">
							<col width="50px">
							<col width="100px">
							<col width="60px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>신청일</th>
								<td>
									<div class="form-row inline-pd" style="max-width: 280px;">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="시작일자" value="">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="" alt="종료일자">
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
								<th>고객명</th>
								<td>
									<div>
			                     		<input type="text" id="s_cust_name" name="s_cust_name" class="form-control" style="width: 100px; display: inline-block;">
			                     	</div>
								</td>
								<th>연락처</th>
								<td>
									<div>
			                     		<input type="text" id="s_hp_no" name="s_hp_no" class="form-control" style="width: 100px; display: inline-block;">
			                     	</div>
								</td>
								<th>센터</th>
								<td>
									<select class="form-control width100px" name="s_org_code">
										<option value="">- 전체 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}"
													<c:if test="${SecureUser.org_type eq 'CENTER' && SecureUser.org_code eq item.org_code}">selected</c:if>
											>${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>구분</th>
								<td>
									<select class="form-control" id="s_extend_yn" name="s_extend_yn">
										<option value="">- 전체 -</option>
										<option value="N">렌탈신청</option>
										<option value="Y">연장신청</option>
									</select>
								</td>
								<th>처리상태</th>
								<td>
									<select class="form-control" id="s_complete_yn" name="s_complete_yn">
										<option value="">- 전체 -</option>
										<option value="Y">종결</option>
										<option value="N">미처리</option>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch()"  >조회</button>
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
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<div class="form-check form-check-inline">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</c:if>
							</div>
							<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
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