<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > ARS결제요청
-- 작성자 : 최보성
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
	<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		
		$(document).ready(function() {
			createAUIGrid(); 
			fnInit();
		});
		
		//초기날짜 세팅
		function fnInit() {
			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.toDate(now));
			$M.setValue("s_end_dt", $M.toDate(now));
			
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
		}
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				rowIdField : "row",
				enableSorting : true,
			};
			var columnLayout = [
				{ 
					headerText : "관리번호", 
					dataField : "ars_reserve_no", 
					width : "13%", 
				},
				{ 
					headerText : "요청일", 
					dataField : "reg_date",
					dataType : "date",
					width : "10%", 
					formatString : "yyyy-mm-dd",
				},
				{ 
					headerText : "처리명", 
					dataField : "lgd_productinfo", 
					width : "10%", 
				},
				{ 
					headerText : "휴대폰", 
					dataField : "lgd_buyerphone", 
					width : "15%", 
				},
				{ 
					headerText : "결제금액", 
					dataField : "lgd_amount", 
					width : "12%", 
					dataType : "numeric"
				},
				{ 
					headerText : "처리결과", 
					dataField : "lgd_respmsg", 
					width : "20%", 
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (value == "" || value == null || value == undefined) {
							value = item.ars_status_name;
						}
						return value;
					}
				},
				{ 
					headerText : "요청인", 
					dataField : "cust_name",
					width : "10%", 
				},
				{
					headerText : "결제취소요청",
					dataField : "cancel_btn",
					width : "10%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							goCancel(event.item);
						},
						visibleFunction   :  function(rowIndex, columnIndex, value, item, dataField ) {
							// ARS 요청 상태, ARS 취소안됐을 경우에만 결제취소 가능 
							if(item.ars_status_cd == "01" && item.cancel_yn == "N") {
							  	return true;
							} else {
							  	return false;
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '결제취소요청'
					},
					style : "aui-center aui-editable",
					editable : false,
				},
				{
					dataField : "lgd_reservenumber",
					visible : false
				},
				{
					dataField : "cancel_yn",
					visible : false
				},
				{
					dataField : "lgd_status",
					visible : false
				},
				{
					dataField : "ars_status_cd",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
		}
		
		//조회
		function goSearch() {
			var param = {
				s_start_dt : $M.getValue("s_start_dt")		//기간
				, s_end_dt : $M.getValue("s_end_dt")		//기간
				, cust_no : $M.getValue("cust_no")			//고객번호
				, ars_status : $M.getValue("ars_status") 	//ars처리상태
			}
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		// 창닫기
		function fnClose() {
			 window.close(); 
		}
		
		//ars 요청 취소
		function goCancel(item) {
			
			var param = {
					ars_reserve_no : item.ars_reserve_no
// 					, lgd_reservenumber : item.lgd_reservenumber
// 					, lgd_amount : item.lgd_amount
// 					, cust_name : item.cust_name
// 					, lgd_buyerphone : item.lgd_buyerphone
			}
			var msg = "요청 자료를 취소처리 하시겠습니까?\n처리 후 복구가 불가능합니다."
			$M.goNextPageAjaxMsg(msg, this_page + "/arsRequestCancel", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					goSearch();
			});
		}
		
		function fnCheckHpNo(mobile) {
			var chkNo = mobile.replace(/-/gi,'');
			if(chkNo.length == 11 || chkNo.length == 10) {
				var regExp_ctn = /^(01[016789]{1}|02|0[3-9]{1}[0-9]{1})([0-9]{3,4})([0-9]{4})$/;
				if(!regExp_ctn.test(chkNo)) {
					return false;
				}
			} else {
				return false;
			}
			return true;
		}
		
		//ars 요청
		function goArsRequest() {
			if(!fnCheckHpNo($M.getValue("lgd_buyerphone").trim())) {
				alert("유효하지 않은 핸드폰번호입니다.");
				return;
			}
			
			if(isNaN($M.getValue("lgd_amount"))) {
				alert("결제금액이 숫자가 아닙니다.");
				return;
			}
// 			if($M.getValue("sms_send_yn") == "N") {
// 				alert("핸드폰(" + $M.getValue("lgd_buyerphone") + ") 번호는 발송오류자료입니다.")
// 				return;
// 			}
			
			 if($M.toNum($M.getValue("lgd_amount")) < ${pay_min_amt}) {
				alert("거래금액 오류입니다.(최소금액 ${pay_min_amt}원)");
				return;
			} 
			if($M.getValue("lgd_productinfo").trim() == "") {
				alert("처리명을 반드시 입력하시오");
				return;
			}
			if($M.getValue("lgd_buyerphone").trim() == "") {
				alert("발송번호 반드시 입력하시오");
				return;
			}
			
			var msg = "예약번호:yyyymmdd0000\n"+$M.getValue("lgd_productinfo") + "W" + $M.getValue("lgd_amount") + "\n통화버튼자동연결\n국민카드제외"
			
			var param = {
					cust_no : $M.getValue("cust_no")
					, lgd_productinfo : $M.getValue("lgd_productinfo")
					, lgd_buyerphone : $M.getValue("lgd_buyerphone")
					, lgd_amount : $M.getValue("lgd_amount")
			}
			$M.goNextPageAjaxMsg(msg, this_page + "/arsRequest", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
		    			goSearch();
					}
				}
			);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="cust_no" id="cust_no" value="${custInfo.cust_no}">
<input type="hidden" name="sms_send_yn" id="sms_send_yn" value="${custInfo.sms_send_yn }"> 
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>					
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="270px">
							<col width="65px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>조회기간</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_current_dt}">
											</div>
										</div>
									</div>
								</td>
								<th>처리상태</th>
								<td>
									<select class="form-control" id="ars_status" name="ars_status">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['ARS_STATUS']}">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<td class=""><button type="button" onclick="goSearch()" class="btn btn-important" style="width: 50px;">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
                <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
<!-- ARS결제 등록 -->
				<div class="title-wrap mt10">
					<h4>ARS결제 등록</h4>					
				</div>
                <table class="table-border mt5">
                    <colgroup>
                        <col width="80px">
                        <col width="">
                        <col width="80px">
                        <col width="">
                        <col width="80px">
                        <col width="">
                    </colgroup>
                    <tbody>
                        <tr>
                            <th class="text-right">고객명</th>
                            <td>${custInfo.cust_name }</td>				
                            <th class="text-right">처리명</th>
                            <td><input type="text" class="form-control" id="lgd_productinfo" name="lgd_productinfo" value="${custInfo.cust_name}"></td>	
                            <th class="text-right">결제금액</th>
                            <td><input type="text" id="lgd_amount" name="lgd_amount" value="${amount }" class="form-control text-right"></td>			
                        </tr>	
                        <tr>
                            <th class="text-right">휴대폰</th>
                            <td>${custInfo.hp_no }</td>				
                            <th class="text-right">발송번호</th>
                            <td><input type="text" id="lgd_buyerphone" name="lgd_buyerphone" value="${custInfo.hp_no }" format="phone" class="form-control"></td>
                            <th class="text-right">거래번호</th>
                            <td></td>			
                        </tr>								
                    </tbody>
                </table>
<!-- /ARS결제 등록 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
                    <button type="button" onclick="goArsRequest()" class="btn btn-success">결재요청</button>
                    <button type="button" onclick="fnClose()" class="btn btn-info">닫기</button>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->	
</form>
</body>
</html>