<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 운송사별운임정산 > 운송사별집계 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		
		$(document).ready(function () {
			createAUIGrid();
			fnInit();
			
		});
		
		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
			
			console.log("click_yn : ", "${inputParam.click_yn}");
			console.log("start_dt : ", "${inputParam.s_start_dt}");
			
			// 전체집계 텝에서 운송사 클릭하여 넘어왔을경우 검색조건을 동일하게 가져가기 위하여 검색조건 세팅
			if ("${inputParam.click_yn}" == "Y") {
				$M.setValue("s_transport_cmp_cd", "${inputParam.s_code_value}");
				$M.setValue("s_start_dt", "${inputParam.s_start_dt}");
				$M.setValue("s_end_dt", "${inputParam.s_end_dt}");
				$M.setValue("s_calc_yn", "${inputParam.s_calc_yn}");
				$M.setValue("s_all_calc_yn", "${inputParam.s_all_calc_yn}");
			} else {
				$M.setValue("s_start_dt", "${searchDtMap.s_start_dt}");
				$M.setValue("s_end_dt", "${searchDtMap.s_end_dt}");
				goSearch();
			}
		}
		
		// 조회
		function goSearch() {
			var param = {
					s_code_value : $M.getValue("s_transport_cmp_cd"),  // 운송사
					s_calc_yn : $M.getValue("s_calc_yn"),  // 처리구분 - (미정산분(Y), 전체(N))
					s_all_calc_yn : $M.getValue("s_all_calc_yn"),  // 작성기간전 미정산자료포함여부 (Y 포함)
					s_start_dt : $M.getValue("s_start_dt"),
					s_end_dt : $M.getValue("s_end_dt"),
					"s_date_type" :  'out_dt', //$M.getValue("s_date_type"), // 고정
					"s_org_code" : $M.getValue("s_org_code"),
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
				};
			//_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}		
			);	
		}

		// 별도운임등록
		function goNew() {
			$M.goNextPage("/acnt/acnt020401");
		}
		
		// 정산처리
		function goCalcProcess() {
			var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
			
			if (checkedItems.length == 0) {
				alert("항목을 선택 해 주세요.");
				return;
			}
			
			if (confirm("정산처리 하시겠습니까 ?") == false) {
				return false;
			}
			
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var transportProcDt = $M.getValue("transport_proc_dt"); // 정산일자
			var memNo = "${inputParam.mem_no}";						// 정산자
			
			console.log(checkedItems);
			
			var machineOutDocSeq = []
// 			var machineDocNo = [];
			var machineDeliveryNo = [];
			var transportMemNo = [];
			var transportProcDt = [];
			
			for (var i = 0; i < checkedItems.length; i++) {
				var machineNo = checkedItems[i].item.machine_no;
				// 관리번호가 'MD' 로 시작할경우 별도운임목록이다.
				
				if (machineNo.startsWith('MD')) {
					machineDeliveryNo.push(checkedItems[i].item.machine_no);
// 					transportMemNo.push(memNo);
// 					transportProcDt.push(transportProcDt);
				} else {
					machineOutDocSeq.push(checkedItems[i].item.machine_out_doc_seq);
// 					transportMemNo.push(memNo);
// 					transportProcDt.push(transportProcDt);
				}
			}
			
			var option = {
					isEmpty : true
			};
			
			$M.setValue(frm, "transport_mem_no", memNo);
			$M.setValue(frm, "machine_out_doc_seq_str", $M.getArrStr(machineOutDocSeq, option));
			$M.setValue(frm, "machine_delivery_no_str", $M.getArrStr(machineDeliveryNo, option));
// 			$M.setValue(frm, "transport_mem_no_str", $M.getArrStr(transportMemNo, option));
// 			$M.setValue(frm, "transport_proc_dt_str", $M.getArrStr(transportProcDt, option));
			
			console.log(frm);
			
			$M.goNextPageAjax(this_page + "/proc/process", frm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("정산처리가 완료되었습니다.");
		    			location.reload();
					}
				}
			);
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "운송사별 운임정산", exportProps);
		}
		
		function createAUIGrid() {
			var gridPros = {
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : false,
				showFooter : true,
				footerPosition : "top",
				enableFilter :true,
				// 고정칼럼 카운트 지정
				// fixedColumnCount : 4
			};

			var columnLayout = [
				{
					dataField : "machine_out_doc_seq",
					visible : false
				},
				{
					dataField : "machine_doc_type_cd",
					visible : false
				},
				{
					headerText : "관리번호",
					dataField : "machine_no",
					style : "aui-center aui-popup",
					width : "70",
					minWidth : "65",
					filter : {
						showIcon : true
					},
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
	                  var ret = "";
	                  if (value != null && value != "") {
	                     ret = value.split("-");
	                     ret = ret[0]+"-"+ret[1];
	                     ret = ret.substr(4, ret.length);
	                  }
	                   return ret; 
	               }, 
				},
				{
					headerText : "운송사명",
					dataField : "transport_cmp_name",
// 					width : "12%",
					filter : {
						showIcon : true
					},
					visible : false
				},
				{
					headerText : "출고일시",
					dataField : "out_dt",
					dataType : "date",  
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "65",
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width : "160",
					minWidth : "110",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "처리건수",
					dataField : "",
					children : [
						{
							headerText : "도착지",
							dataField : "arrival_area_name",
							style : "aui-left",
							width : "150",
							minWidth : "50",
						},
						{
							headerText : "운임",
							dataField : "transport_amt",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							width : "80",
							minWidth : "80",
						},
						{
							headerText : "부서",
							dataField : "org_name",
							width : "65",
							minWidth : "65",
						},
						{
							headerText : "처리자",
							dataField : "out_mem_name",
							width : "65",
							minWidth : "65",
						},
						{
							headerText : "정산일자",
							dataField : "transport_proc_dt",
							dataType : "date",  
							formatString : "yy-mm-dd",
							width : "65",
							minWidth : "65",
						}
					]
				},
				{
					headerText : "마케팅작성",
					dataField : "",
					children : [
						{
							headerText : "작성일자",
							dataField : "reg_date",
							dataType : "date",  
							formatString : "yy-mm-dd",
							visible : false
						},
						{
							headerText : "담당자",
							dataField : "reg_mem_name",
							visible : false
						},
						{
							headerText : "고객명",
							dataField : "cust_name",
							width : "65",
							minWidth : "65",
						},
						{
							headerText : "연락처",
							dataField : "hp_no",
							width : "100",
							minWidth : "100",
						},
						{
							headerText : "모델명",
							dataField : "machine_name",
							width : "100",
							minWidth : "60",
							style : "aui-left"
						},
						{
							headerText : "합계금액",
							dataType : "numeric",
							formatString : "#,##0",
							dataField : "total_amt",
							style : "aui-right",
							width : "10%",
							visible : false
						},
					]
				},
				{
					headerText : "별도운임",
					dataField : "",
					children : [
						{
							headerText : "품목",
							dataField : "prod_name",
							style : "aui-left",
							width : "100",
							minWidth : "50",
						},
						{
							headerText : "수량(비고)",
							dataField : "remark",
							width : "200",
							minWidth : "30",
						}
					]
				}
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "arrival_area_name",
					style: "aui-center aui-footer"
				},
				{
					dataField: "transport_amt",
					positionField: "transport_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "total_amt",
					positionField: "total_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
			];
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);		

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "machine_no") {
					console.log("event : ", event);
					if (event.item.machine_no.startsWith('MD')) {
						console.log("별도운임");
						if (event.item.transport_proc_dt == "") {
							var param = {
									machine_delivery_no : event.item.machine_no
							}
							var poppupOption = "";
							$M.goNextPage('/acnt/acnt0204p01', $M.toGetParam(param), {popupStatus : poppupOption});
						} else {
							alert("정산처리가 완료된 항목입니다.");
						}
					} else {
						if (event.item.machine_doc_type_cd == 'SALE') {
							console.log("출하의뢰서");
							var param = {
									machine_doc_no : event.item.machine_no
							}
// 							var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=700, left=0, top=0";
							var poppupOption = "";
							$M.goNextPage('/sale/sale0101p03', $M.toGetParam(param), {popupStatus : poppupOption});
						} else {
							console.log("stock");
							var param = {
									machine_doc_no : event.item.machine_no
							}
// 							var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=700, left=0, top=0";
							var poppupOption = "";
							$M.goNextPage('/sale/sale0101p09', $M.toGetParam(param), {popupStatus : poppupOption});
						}
					}
				}
			});
			
			// 정산처리 완료된 내역 체크 선택 X
			AUIGrid.bind(auiGrid, "rowCheckClick", function( event ) {
				if(event.item.transport_proc_dt != ""){
					alert("이미 정산처리가 완료된 내역입니다.");
					AUIGrid.addUncheckedRowsByValue(auiGrid, "machine_no", event.item.machine_no);
					return;
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
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
<%--								<col width="0px">--%>
								<col width="100px">
								<col width="270px">
								<col width="40px">
								<col width="120px">
								<col width="60px">
								<col width="120px">
								<col width="65px">
								<col width="120px">
								<col width="190px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>작성기간</th>
<%--								<td>--%>
<%--									<select name="s_date_type" id="s_date_type" class="form-control width100px">--%>
<%--										<option value="reg_date">작성기간</option>--%>
<%--										<option value="transport_proc_dt">정산기간</option>--%>
<%--									</select>--%>
<%--								</td>							--%>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-5">
											<div class="input-group">
												<!-- script에서 기간 세팅 -->
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<!-- script에서 기간 세팅 -->
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" value="">
											</div>
										</div>
<%-- 										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp"> --%>
<%-- 				                     		<jsp:param name="st_field_name" value="s_start_dt"/> --%>
<%-- 				                     		<jsp:param name="ed_field_name" value="s_end_dt"/> --%>
<%-- 				                     		<jsp:param name="click_exec_yn" value="Y"/> --%>
<%-- 				                     		<jsp:param name="exec_func_name" value="goSearch();"/> --%>
<%-- 			                     		</jsp:include> --%>
									</div>
								</td>		
								<th>부서</th>
								<td>
									<select class="form-control" id="s_org_code" name="s_org_code">
										<option value="">- 선택 -</option>
										<c:forEach items="${orgList}" var="item">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>운송사</th>
								<td>
									<select class="form-control width160px" id="s_transport_cmp_cd" name="s_transport_cmp_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['TRANSPORT_CMP']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>처리구분</th>
								<td>
									<select class="form-control" id="s_calc_yn" name="s_calc_yn">
										<option value="N">미정산분</option>
										<option value="Y">정산분</option>
										<option value="A">전체</option>
									</select>
								</td>			
								<td class="pl10">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" value="Y" id="s_all_calc_yn" name="s_all_calc_yn">
										<label class="form-check-label" for="s_all_calc_yn">작성기간전 미정산자료포함</label>
									</div>
								</td>																			
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="right">
							<div class="input-group">
								<div class="right dpf">
									<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<div class="form-check form-check-inline">
										<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
										<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
									</div>
									</c:if>										
									<div class="input-group mr5" style="width: 100px;">
										<input type="text" class="form-control border-right-0 calDate" id="transport_proc_dt" name="transport_proc_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}">
									</div>
									<div>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
						</div>
					</div>
					<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>