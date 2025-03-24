<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 영업관리 > 출하종결처리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
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
			fnInit();
		});

		// 조회
		function goSearch() {
			if($M.getValue("s_start_dt") == '' && $M.getValue('s_end_dt') == '') {
				alert('출고일을 선택해주세요.');
				return;
			}
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

		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
			goSearch();
		}

		function fnSearch(successFunc) {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {
				return;
			};
			isLoading = true;
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_out_confirm_yn : $M.getValue("s_out_confirm_yn"),
				s_org_gubun_cd : $M.getValue("s_org_gubun_cd"),
				s_sort_key : "machine_doc_no",
				s_sort_method : "desc",
				page : page,
				rows : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					/* if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}; */
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			);
		}

		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y"  && isLoading == false) {
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
			  var exportProps = {};
			  fnExportExcel(auiGrid, "출하종결처리내역", exportProps);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "machine_doc_no",
				height : 555,
				rowIdTrustMode : true,
				enableFilter :true,
				showFooter : true,
				footerPosition : "top"
			};
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "machine_doc_no",
					width : "70",
					minWidth : "65",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
		                  var ret = "";
		                  if (value != null && value != "") {
		                     ret = value.split("-");
		                     ret = ret[0]+"-"+ret[1];
		                     ret = ret.substr(4, ret.length);
		                  }
		                   return ret;
		            },
					filter : {
						showIcon : true
					},
					style : "aui-center aui-popup"
				},
				{
					headerText : "지점",
					dataField : "org_kor_name",
					width : "80",
					minWidth : "75",
					filter : {
						showIcon : true
					},
					style : "aui-center",
				},
				{
					headerText : "담당자",
					dataField : "doc_mem_name",
					width : "70",
					minWidth : "65",
					filter : {
						showIcon : true
					},
					style : "aui-center"
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "80",
					minWidth : "75",
					filter : {
						showIcon : true
					},
					style : "aui-center"
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "100",
					minWidth : "75",
					filter : {
						showIcon : true
					},
					style : "aui-center"
				},
				{
					headerText : "출고일",
					dataField : "out_dt",
					dataType : "date",
					width : "80",
					minWidth : "75",
					style : "aui-center aui-popup",
					formatString : "yyyy-mm-dd"
				},
				{
					headerText : "판매가",
					dataField : "sale_price",
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "75",
					style : "aui-right"
				},
				{
					headerText : "센터정산",
					children: [
						{
							headerText : "정산센터",
							dataField : "account_org_name",
							width : "70",
							minWidth : "70",
							style : "aui-cetner",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
							    return item.org_gubun_cd != 'AGENCY' ? value : "";
							},
						},
						{
							headerText : "할인",
							dataField : "discount_amt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "80",
							minWidth : "75",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
							    return item.org_gubun_cd != 'AGENCY' ? $M.setComma(value) : "";
							},
						},{
							headerText : "판매금액",
							dataField : "sale_amt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "80",
							minWidth : "75",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.org_gubun_cd != 'AGENCY' ? $M.setComma(value) : "";
							},
						}
					]
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점정산",
					headerText : "위탁판매점정산",
					children: [
						{
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// headerText : "대리점가",
							headerText : "위탁판매점가",
							dataField : "agency_price",
							dataType : "numeric",
							formatString : "#,##0",
							width : "80",
							minWidth : "75",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.org_gubun_cd == 'AGENCY' ? $M.setComma(value) : "";
							},
						},{
							headerText : "판매수수료",
							dataField : "sale_commission_amt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "80",
							minWidth : "75",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.org_gubun_cd == 'AGENCY' ? $M.setComma(value) : "";
							},
						}
					]
				},
				{
					headerText : "서비스이관료",
					dataField : "service_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "80",
					minWidth : "75",
					style : "aui-right",
				},
				{
					headerText : "서비스정산",
					dataField : "service_account_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "80",
					minWidth : "75",
					style : "aui-right",
				},
				{
					headerText : "중고매입금액",
					dataField : "used_price",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					width : "80",
					minWidth : "75",
				},
				{
					headerText : "VAT",
					dataField : "vat",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					width : "80",
					minWidth : "75",
				},
				{
					dataField : "machine_out_doc_seq",
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "out_dt"
				},{
					dataField : "sale_price",
					positionField : "sale_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},{
					dataField : "discount_amt",
					positionField : "discount_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},{
					dataField : "agency_price",
					positionField : "agency_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},{
					dataField : "sale_commission_amt",
					positionField : "sale_commission_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},{
					dataField : "service_amt",
					positionField : "service_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},{
					dataField : "service_account_amt",
					positionField : "service_account_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},{
					dataField : "used_price",
					positionField : "used_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},{
					dataField : "vat",
					positionField : "vat",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'machine_doc_no') {
					var params = {
						"machine_doc_no" : event.item["machine_doc_no"]
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
				} else if(event.dataField == 'out_dt') {
					var params = {
						"machine_out_doc_seq" : event.item["machine_out_doc_seq"]
					};
					if(event.item.org_gubun_cd == 'AGENCY') {
						var docNo = {
							machine_doc_no : event.item["machine_doc_no"]
						}
						// Q&A 12086 이금님 사원님 임시요청. 210728 김상덕
// 						$M.goNextPageAjax(this_page + "/docCheck", $M.toGetParam(docNo), {method : 'get'},
// 							function(result) {
// 								if(result.success) {
// 									if (result.pass != "Y") {
// 										alert("DI리포트 제출서류를 확인하세요.");
// 										var poppupOption = "";
// 										$M.goNextPage('/sale/sale0101p03', $M.toGetParam(docNo), {popupStatus : poppupOption});
// 									} else {
										var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=730, height=410, left=0, top=0";
										$M.goNextPage('/sale/sale0301p02', $M.toGetParam(params), {popupStatus : poppupOption});
// 									}
// 								};
// 							}
// 						);
					} else {
						var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=730, height=400, left=0, top=0";
						$M.goNextPage('/sale/sale0301p01', $M.toGetParam(params), {popupStatus : poppupOption});
					}
				}
			});
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
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
								<col width="60px">
								<col width="260px">
								<col width="55px">
								<col width="70px">
								<col width="80px">
								<col width="70px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>출고일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt }">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt }">
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
									<th>조직구분</th>
									<td>
										<select class="form-control" name="s_org_gubun_cd">
											<option value="">- 전체 -</option>
											<option value="BASE#CENTER">본사</option>
											<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
											<%-- <option value="AGENCY">대리점</option> --%>
											<option value="AGENCY">위탁판매점</option>
										</select>
									</td>
									<th>처리구분</th>
									<td>
										<select class="form-control" name="s_out_confirm_yn">
											<option value="">- 전체 -</option>
											<option value="N">미결</option>
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
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="margin-top: 5px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
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
