<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 할인쿠폰관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-09-21 15:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridLeft();
			createAUIGridRight();
// 			fnInit();
			goSearch();
		});
		
		
// 		function fnInit() {
// 			// 설정기간 (1개월 전 ~ 당일)
// 			$M.setValue("s_gubun_start_dt", $M.addMonths($M.toDate($M.getValue("s_gubun_end_dt")), -1));
// 		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name","s_coupon_issue_cd", "s_date_type","s_balance_amt_non_zero"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}

		//조회
		function goSearch() { 
			
			if($M.checkRangeByFieldName("s_gubun_start_dt", "s_gubun_end_dt", true) == false) {				
				return;
			}; 
			
			
			var param = {
					"s_sort_key" : "issue_dt", 
					"s_sort_method" : "desc",
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_coupon_issue_cd" : $M.getValue("s_coupon_issue_cd"),
					"s_date_type" : $M.getValue("s_date_type"),
					"s_balance_amt_non_zero" : $M.getValue("s_balance_amt_non_zero"),
					"s_gubun_start_dt" : $M.getValue("s_gubun_start_dt"),
					"s_gubun_end_dt" : $M.getValue("s_gubun_end_dt"),
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			_fnAddSearchDt(param, 's_gubun_start_dt', 's_gubun_end_dt');
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridLeft, result.list);

						// 요청예정목록 초기화
						AUIGrid.setGridData(auiGridRight, []);	
						$M.setValue("cust_name","");
						$M.setValue("cust_no","");
						$M.setValue("hp_no","");
						$M.setValue("sum_balance_amt","");	
						$M.setValue("last_dt","");	
						
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		} 
		
		//그리드생성
		function createAUIGridLeft() {
			var gridPros = {
					rowIdField : "$uid",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
					showBranchOnGrouping : false,
					showFooter : true,
					footerPosition : "top",
					editable : false,
					enableMovingColumn : false
				};
			var columnLayout = [
				{
					headerText : "발행일자", 
					dataField : "issue_dt", 
					dataType : "date",
		            formatString : "yy-mm-dd",	
					width : "80",
					minWidth : "70",
					style : "aui-center"
				},
				{ 
					dataField : "cust_coupon_no", 
					visible : false
				},
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no", 
					width : "95",
					minWidth : "90",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{ 
					dataField : "cust_no", 
					visible : false
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "95",
					minWidth : "90",
					style : "aui-center",
				},
				{ 
					headerText : "연락처", 
					dataField : "cust_hp_no", 
					width : "110",
					minWidth : "110",
					style : "aui-center"
				},
				{ 
					headerText : "쿠폰구분", 
					dataField : "coupon_issue_name", 
					width : "80",
					minWidth : "70",
					style : "aui-center",
				},
				{ 
					headerText : "쿠폰금액", 
					dataField : "coupon_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "80",
					style : "aui-right",
				},
				{ 
					headerText : "쿠폰잔액", 
					dataField : "balance_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "80",
					style : "aui-right",
				},
				{ 
					headerText : "소멸예정일", 
					dataField : "expire_plan_dt", 
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "80",
					minWidth : "70",
					style : "aui-center",
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "issue_dt",
					style : "aui-center aui-footer",
					colSpan : 7
				}, 
				{
					dataField : "coupon_amt",
					positionField : "coupon_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}, 
				{
					dataField : "balance_amt",
					positionField : "balance_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			

			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridLeft, footerColumnLayout);
			AUIGrid.setGridData(auiGridLeft, []);
			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				if(event.dataField == "inout_doc_no") {
					var frm = document.main_form;
					
	 				var custNo = event.item["cust_no"];
	 				var issueDt = event.item["issue_dt"];
					 goCustCouponInfo(custNo,issueDt);
				}
				
			});	
			$("#auiGridLeft").resize();
		}
		
		// 처리내역 조회
		function goCustCouponInfo(custNo,issueDt) {
			var param = {
				"s_cust_no" : custNo,
				"s_issue_dt" : issueDt,
				"s_sort_key" : "inout_dt asc, inout_doc_no",
				"s_sort_method" : "asc",
			};
			$M.setValue("cust_no",custNo);
					
			$M.goNextPageAjax(this_page + "/searchDetail", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGridRight, result.couponInfoList);
						
						$M.setValue("cust_name" , result.couponInfoMap.cust_name);
						$M.setValue("hp_no" , result.couponInfoMap.hp_no);
						$M.setValue("sum_balance_amt" , result.couponInfoMap.sum_balance_amt);					
						$M.setValue("last_dt" , result.couponInfoMap.last_dt);
						
					};
				}	
			);
		}
		
		//그리드생성
		function createAUIGridRight() {
			var gridPros = {
					rowIdField : "$uid",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
					showBranchOnGrouping : false,
					editable : false,
					enableMovingColumn : false
				};
			var columnLayout = [
				{
					headerText : "처리일자", 
					dataField : "inout_dt", 
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "70",
					style : "aui-center"
				},
				{ 
					dataField : "cust_coupon_no", 
					visible : false
				},
				{ 
					dataField : "cust_no", 
					visible : false
				},
				{ 
					dataField : "inout_doc_no", 
					visible : false
				},		
				{ 
					dataField : "job_report_no", 
					visible : false
				},				
				{ 
					dataField : "input_type_cd", 
					visible : false
				},
				{ 
					dataField : "inout_doc_type_cd", 
					visible : false
				},
			
				{ 
					headerText : "구분", 
					dataField : "inout_type_name", 
					width : "70",
					minWidth : "70",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {						
						if(item.inout_type_cd != "26"){								
							return "aui-popup";
						}						   
					}
				},
				{ 
					headerText : "금액", 
					dataField : "coupon_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "85",
					minWidth : "80",
					style : "aui-right",
				},
				{ 
					headerText : "잔액", 
					dataField : "balance_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "85",
					minWidth : "80",
					style : "aui-right",
				},
				{ 
					headerText : "비고", 
					dataField : "remark", 
					style : "aui-left",
				}
			];
			
			
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
			$("#auiGridRight").resize();
			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
				
				if(event.item.cust_no == "" && event.item.cust_coupon_no == "" ){
					alert("고객쿠폰을 선택해주세요");
					return;
				}
				else {
					if(event.dataField == "inout_type_name") {	
						
						//이월인경우 팝업띄우지않음
						if(event.item.inout_type_cd == "26") {
							return;
						}
						//할인쿠폰상세 ( 거래구분 - 쿠폰 )
						else if(event.item.inout_type_cd == "15") {

							var params = {
									"cust_coupon_no" : event.item.cust_coupon_no
							};
							var popupOption = "";
							$M.goNextPage('/cust/cust0305p01', $M.toGetParam(params), {popupStatus : popupOption});
						} 						
						else {
							
							//수주
							if(event.item.inout_doc_type_cd == "05") {
								var params = {
									"inout_doc_no" : event.item.inout_doc_no
								};
								
								var popupOption = "";
								$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
							}
							//서비스 정비 거래명세서
							if(event.item.inout_doc_type_cd == "07") {
								var params = {
									"inout_doc_no" : event.item.inout_doc_no
								};
								
								var popupOption = "";
								//팝업 확인 중
								$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
							}
							
						}
					}								
				}				
			});	
		}
		
		function goCostProcess() {
						
			if($M.getValue("cust_name") == "" ){
				alert("고객을 선택해주세요");
				return;
			}

			var params = {
				"cust_no" : $M.getValue("cust_no")
			};
			
			//현재 고객을 세팅후 신규등록 페이지로 이동하기 ( 팝업 )
			var popupOption = "";
			$M.goNextPage('/cust/cust030501', $M.toGetParam(params), {popupStatus : popupOption});

		}

	    function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGridLeft, "할인쿠폰관리", exportProps);
		}
		
		function goNew() {
	
				// 신규등록 페이지로 이동하기 ( 팝업 )
				var popupOption = "";
				$M.goNextPage('/cust/cust030501', "", {popupStatus : popupOption});
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
<%--				<div class="main-title">--%>
<%--				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>--%>
<%--				</div>--%>
<!-- /메인 타이틀 -->
				<div class="contents" style="margin-top: 10px">
				
					<input type="hidden" id="cust_no" name="cust_no" > 
					
					<div class="row">
						<div class="col-7">
<!-- 검색영역 -->					
							<div class="search-wrap">				
								<table class="table">
									<colgroup>
										<col width="90px">
										<col width="270px">								
										<col width="50px">
										<col width="120px">
										<col width="40px">
										<col width="100px">
										<col width="140px">
										<col width="">
									</colgroup>
									<tbody>
										<tr>
											<td>
												<select class="form-control" id="s_date_type" name="s_date_type">
													<option value="issue_dt">발행일자</option>
													<option value="expire_plan_dt">소멸예정일</option>
												</select>
											</td>
											<td>
												<div class="form-row inline-pd">
													<div class="col-5">
														<div class="input-group dev_nf">
															<input type="text" class="form-control border-right-0 calDate" id="s_gubun_start_dt" name="s_gubun_start_dt" value="${searchDtMap.s_start_dt}" dateformat="yyyy-MM-dd" alt="조회 시작일" >
														</div>
													</div>
													<div class="col-auto">~</div>
													<div class="col-5">
														<div class="input-group dev_nf">
															<input type="text" class="form-control border-right-0 calDate" id="s_gubun_end_dt" name="s_gubun_end_dt" dateformat="yyyy-MM-dd" alt="조회 완료일" value="${searchDtMap.s_end_dt}" >
														</div>
													</div>
													<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
						                     		<jsp:param name="st_field_name" value="s_gubun_start_dt"/>
						                     		<jsp:param name="ed_field_name" value="s_gubun_end_dt"/>
						                     		<jsp:param name="click_exec_yn" value="Y"/>
						                     		<jsp:param name="exec_func_name" value="goSearch();"/>
						                     		</jsp:include>	
												</div>	
											</td>
											<th>고객명</th>
											<td>
												<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
											</td>
											<th>구분</th>
											<td>
												<select class="form-control" id="s_coupon_issue_cd" name="s_coupon_issue_cd">
													<option value="">- 전체 - </option>
													<c:forEach var="item" items="${codeMap['COUPON_ISSUE']}">
														<option value="${item.code_value}">${item.code_name}</option>										
													</c:forEach>													
												</select>
											</td>
											<td class="pl10">
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="checkbox"  id="s_balance_amt_non_zero" name="s_balance_amt_non_zero"   value="Y"  checked="checked" >
													<label class="form-check-label" for="s_balance_amt_non_zero"  >잔액있는 쿠폰만</label>
												</div>
											</td>
											<td>
												<button type="button" class="btn btn-important" style="width: 50px;" onclick="javasctipt:goSearch();">조회</button>
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
									<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<div class="form-check form-check-inline">
										<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
										<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
									</div>
									</c:if>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
								</div>
							</div>
							<div id="auiGridLeft" style="margin-top: 5px; height: 555px;"></div>
<!-- /조회결과 -->					
						</div>
						<div class="col-5">
<!-- 폼테이블 -->							
							<table class="table-border">
								<colgroup>
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">고객명</th>
										<td>
											<input type="text" class="form-control width120px" id="cust_name" name="cust_name" readonly="readonly" >
										</td>
										<th class="text-right">연락처</th>
										<td>
											<input type="text" class="form-control width120px" id="hp_no" name="hp_no"  readonly="readonly"    >
										</td>
									</tr>
									<tr>
										<th class="text-right">쿠폰잔액</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width120px">
													<input type="text" class="form-control text-right" id="sum_balance_amt" name="sum_balance_amt"  readonly="readonly" datatype="int" format="decimal" >
												</div>
												<div class="col width16px">원</div>
											</div>
										</td>
										<th class="text-right">최종거래</th>
										<td>
											<input type="text" class="form-control width120px" id="last_dt" name="last_dt" readonly="readonly" dateFormat ="yyyy-mm-dd" >
										</td>
									</tr>																			
								</tbody>
							</table>
<!-- /폼테이블 -->
<!-- 처리내역 -->
							<div class="title-wrap mt10">
								<h4>처리내역</h4>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
							<div id="auiGridRight" style="margin-top: 5px; height: 520px;"></div>
<!-- /처리내역 -->	
						</div>
					</div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
						</div>		
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>				
				</div>
			</div>		
<%--			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>--%>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>