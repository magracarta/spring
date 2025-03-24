<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > SA-R신청관리 > null > null
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-08 13:28:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	var isMachine = true;
	
	$(document).ready(function () {
		createAUIGrid();

		goSearch();
	});

	function goSearch() {
		
		if($M.getValue("s_start_dt") != "" && $M.getValue("s_end_dt") != ""){
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}
		}
		var param = {
				s_contract_select_type : $M.getValue("s_contract_select_type")
				, s_st_dt : $M.getValue("s_start_dt")
				, s_ed_dt : $M.getValue("s_end_dt")
				, s_makername : $M.getValue("s_makername")
				, s_machine_name : $M.getValue("s_machine_name")
				, s_cust_name : $M.getValue("s_cust_name")
				, s_maker_cd : $M.getValue("s_maker_cd")
				, s_body_no : $M.getValue("s_body_no")
				, s_cust_deal_no : $M.getValue("s_cust_deal_no")
				, s_machine_sar_status_cd : $M.getValue("s_machine_sar_status_cd")
				, "s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
				, "s_new_yn" : $M.getValue("s_new_yn")
		}
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result){
				if(result.success) {
					$("#total_cnt").html(result.list.length);
					AUIGrid.setGridData(auiGrid, result.list);
				}
			}
		); 
	}

	function fnDownloadExcel() {
		// 엑셀 내보내기 속성
	 	var exportProps = {
			//제외항목
		};
		fnExportExcel(auiGrid, "SA-R신청관리", exportProps);
	}

	function enter(fieldObj) {
		var field = ["s_body_no", "s_cust_deal_no", "s_cust_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch(document.main_form);
			};
		});
	}
	
	function createAUIGrid() {
		var gridPros = {
			// Row번호 표시 여부
			showRowNumColum : true
		};

		var columnLayout = [
			{
				headerText : "상태",
				dataField : "machine_sar_status_name",
				style : "aui-center",
				width : "45",
				minWidth : "45"
			},
			{
				headerText : "구분",
				dataField : "new_yn",
				style : "aui-center",
				width : "45",
				minWidth : "45",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "Y" ? "신차" : "추가";
				}
			},
			{
				headerText : "고객명",
				dataField : "cust_name",
				style : "aui-center aui-popup",
				width : "105",
				minWidth : "45"
			},
			{
				headerText : "영문명",
				dataField : "cust_eng_name",
				style : "aui-center",
				width : "130",
				minWidth : "45"
			},
			{
				headerText : "연락처",
				dataField : "cust_hp_no",
				style : "aui-center",
				width : "105",
				minWidth : "90"
			},
			{
				headerText : "이메일",
				dataField : "cust_email",
				style : "aui-center",
				width : "150",
				minWidth : "45"
			},
			{
				headerText : "모델명",
				dataField : "machine_name",
				style : "aui-center",
				width : "110",
				minWidth : "45"
			},
			{
				headerText : "출하일",
				dataField : "out_dt",
				dataType : "date",   
				style : "aui-center",
				width : "75",
				minWidth : "75",
				formatString : "yy-mm-dd"
			},
			{
				headerText : "신청일",
				dataField : "req_date",
				dataType : "date",   
				style : "aui-center",
				width : "75",
				minWidth : "75",
				formatString : "yy-mm-dd"
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				style : "aui-center",
				width : "150",
				minWidth : "100"
			},
			{
				headerText : "담당센터",
				dataField : "center_org_name",
				style : "aui-center",
				width : "55",
				minWidth : "45"
			},
			{
				headerText : "마케팅담당자",
				dataField : "sale_mem_name",
				style : "aui-center aui-popup",
				width : "55",
				minWidth : "45"
			},
			{
				headerText : "계약번호",
				dataField : "contract_no",
				style : "aui-center",
				width : "100",
				minWidth : "45"
			},
			{
				headerText : "거래처코드",
				dataField : "cust_deal_no",
				style : "aui-center",
				width : "100",
				minWidth : "45"
			},
			{
				headerText : "계약게시일",
				dataField : "contract_st_dt",
				dataType : "date",   
				style : "aui-center",
				width : "75",
				minWidth : "75",
				formatString : "yy-mm-dd"
			},
			{
				headerText : "계약종료일",
				dataField : "contract_ed_dt",
				dataType : "date",   
				style : "aui-center",
				width : "75",
				minWidth : "75",
				formatString : "yy-mm-dd"
			},
			{
				headerText : "비고",
				dataField : "remark",
				width : "120",
				minWidth : "70",
				style : "aui-left"
			},
			{
				headerText : "장비품의서번호",
				dataField : "machine_doc_no",
				visible : false
			},
			{
				headerText : "장비일련번호",
				dataField : "machine_seq",
				visible : false
			},
			{
				headerText : "고객원본이름",
				dataField : "cust_name_origin",
				visible : false
			},
			{
				headerText : "고객원본번호",
				dataField : "cust_hp_origin",
				visible : false
			}
		];
		

		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
		// AUIGrid.setFixedColumnCount(auiGrid, 6);
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			var param = {
					s_machine_doc_no : event.item.machine_doc_no
					, s_cust_no : event.item.cust_no
			}
			
			if(event.dataField == "cust_name") {
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=590, left=0, top=0";
				$M.goNextPage('/serv/serv0507p01', $M.toGetParam(param), {popupStatus : poppupOption});
			}
			if(event.dataField == "email") {
				var param = {
					'to' : event.item['email']
				};
				openSendEmailPanel($M.toGetParam(param));
			}
			if(event.dataField == "sale_mem_name") {

				var param = {
					'name' : event.item.cust_name_origin,
					'hp_no' : $M.phoneFormat(event.item.cust_hp_origin,'-'),
					'menu_seq' : ${menu_seq},
					'body_no' : event.item.body_no,
					'machine_name' : event.item.machine_name,
					'out_dt' : $M.dateFormat(event.item.out_dt, 'yyyy-MM-dd'),
					'req_msg_yn' : "Y",
				}

				openSendSmsPanel($M.toGetParam(param));
			}
		});
		
	}

	// SA-R 추가등록
	function goNew() {
		var param = {
			s_sar_yn : "Y"
		};
		openSearchCustPanel('goMachineSarInfo', $M.toGetParam(param));
	}

	// SA-R 추가등록 팝업 실행
	function goMachineSarInfo(data) {
		var param = {
			s_machine_seq : data.machine_seq,
		}
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=590, left=0, top=0";
		$M.goNextPage('/serv/serv0507p02', $M.toGetParam(param), {popupStatus : poppupOption});
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
	<!-- 검색영역 -->					
						<div class="search-wrap">				
							<table class="table">
								<colgroup>
									<col width="100px">
									<col width="300px">
									<col width="45px">
									<col width="85px">
									<col width="40px">
									<col width="160px">	
									<col width="70px">
									<col width="80px">
									<col width="80px">
									<col width="80px">	
									<col width="80px">
									<col width="100px">
									<col width="35px">
									<col width="70px">
									<col width="35px">
									<col width="70px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<td>
											<select id="s_contract_select_type" name="s_contract_select_type" class="form-control">
												<option value="a.contract_st_dt">계약게시일</option>
												<option value="a.contract_ed_dt">계약종료일</option>
											</select>
										</td>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width110px">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="조회 시작일" value="${searchDtMap.s_start_dt }">
													</div>
												</div>
												<div class="col width16px text-center">~</div>
												<div class="col width120px">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  alt="조회 완료일" value="${searchDtMap.s_end_dt }">
													</div>
												</div>
												<div style="margin-left: -5px;">
													<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
							                     		<jsp:param name="st_field_name" value="s_start_dt"/>
							                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
							                     		<jsp:param name="click_exec_yn" value="Y"/>
							                     		<jsp:param name="exec_func_name" value="goSearch();"/>
							                     	</jsp:include>
						                     	</div>
											</div>
										</td>
										<th>메이커</th>
										<td>
											<select class="form-control" id="s_maker_cd" name="s_maker_cd">
												<option value="">- 전체 -</option>
												<option value="27">얀마</option>
												<option value="02">겔</option>
												<option value="21">사카이</option>
												<option value="01">가와사키</option>
												<option value="68">마니또</option>
												<option value="46">기타</option>
											</select>
										</td>
										<th>모델</th>
										<td>
											<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
												<jsp:param name="s_maker_cd" value=""/>
					                     	</jsp:include>
										</td>
										<th>고객명</th>
										<td>
											<input type="text" id="s_cust_name" name="s_cust_name" class="form-control width100px" >
										</td>
										<th>차대번호</th>
										<td>
											<input type="text" id="s_body_no" name="s_body_no" class="form-control width100px" >
										</td>
										<th>거래처코드</th>
										<td>
											<input type="text" id="s_cust_deal_no" name="s_cust_deal_no" class="form-control width100px">
										</td>
										<th>상태</th>
										<td>
											<select class="form-control" id="s_machine_sar_status_cd" name="s_machine_sar_status_cd">
												<option value=""> - 전체 -</option>
												<c:forEach var="item" items="${codeMap['MACHINE_SAR_STATUS']}">
													<option value="${item.code_value}"
													<c:if test="${item.code_value eq 'W'}">selected</c:if>
													>${item.code_name}</option>
												</c:forEach>
											</select>
										</td>
										<th>구분</th>
										<td>
											<select class="form-control" id="s_new_yn" name="s_new_yn">
												<option value=""> - 전체 -</option>
												<option value="Y"> 신차 </option>
												<option value="N"> 추가 </option>
											</select>
										</td>
										<td>
											<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
										</td>									
									</tr>						
								</tbody>
							</table>					
						</div>
	<!-- /검색영역 -->
	<!-- 신청내역 -->
						<div class="title-wrap mt10">
							<h4>신청내역</h4>
							<div class="btn-group">
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
	<!-- /신청내역 -->
						<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
							</div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>				
					</div>
				</div>
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>			
			</div>
			
	<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>