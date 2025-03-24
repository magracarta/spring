<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 수주현황/등록 > null > 배송정보
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			createAUIGridBottom();
			fnInfo();
		});
		
		
		// 받아온 정보 셋팅
		function fnInfo() {
			var params = {
	    			cust_no : '${inputParam.cust_no}',
	    			invoice_money_cd : '${inputParam.invoice_money_cd}',
	    			invoice_send_cd : '${inputParam.invoice_send_cd}',
	    			receive_name : '${inputParam.receive_name}',
	    			invoice_no : '${inputParam.invoice_no}',
					bill_no : '${inputParam.bill_no}', // 대신화물 송장번호
	    			receive_hp_no : $M.phoneFormat('${inputParam.receive_hp_no}'),
	    			receive_tel_no : '${inputParam.receive_tel_no}',
	    			qty : '${inputParam.qty}',
	    			remark : '${inputParam.remark}',
	    			post_no : '${inputParam.post_no}',
	    			addr1 : '${inputParam.addr1}',
	    			addr2 : '${inputParam.addr2}',
	    			
	    	};
			$M.setValue(params);
			
			// 고객앱 주문 화물배송이면 대신화물 영업소명 노출
			if('${inputParam.invoice_send_cd}' == "5" && '${inputParam.app_yn}' == "Y"){
				$M.setValue("post_no", "");
				$M.setValue("addr1", "${inputParam.invoice_desc_text}");
				$M.setValue("addr2", "");
			}
			if('${inputParam.invoice_send_cd}' == "") {
				$M.setValue("invoice_send_cd", "0");
			}
			
			if('${inputParam.invoice_money_cd}' == "") {
				$M.setValue("invoice_money_cd", "1");
			}

			// 재호 : print_yn 요청건 -
			if('${inputParam.print_yn}' == "Y") {
				$("#_goSave").hide();
				$("input").prop('readonly', true);
				$("input").prop('disabled', true);
				$("select").prop('disabled', true);
				$("button").prop('disabled', true);
				$("button").removeAttr('onclick');
				$("select[name=invoice_money_cd]").attr("disabled", true);
				// 송장라벨 출력 제외
				$("#_fnPrint").attr('onclick', "fnPrint();");
				$("#_fnPrint").prop('disabled', false);
				// 닫기버튼 제외
				$("#_fnClose").attr('onclick', "fnClose();");
				$("#_fnClose").prop('disabled', false);
			}
			
			if('${inputParam.show_yn}' == "Y") {
				$("#_goSave").hide();
				$("input").prop('readonly', true);
				$("input").prop('disabled', true);
				$("select").prop('disabled', true);
				$("button").prop('disabled', true);
				$("button").removeAttr('onclick');
				$("select[name=invoice_money_cd]").attr("disabled", true); 
				// 닫기버튼 제외
				$("#_fnClose").attr('onclick', "fnClose();");
				$("#_fnClose").prop('disabled', false);
			}
		}
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "send_invoice_seq",
				showRowNumColumn: false,
			};
			var columnLayout = [
				{
					headerText : "전표날짜", 
					dataField : "process_dt", 
					dataType : "date",   
					formatString : "yy-mm-dd",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{ 
					headerText : "전표번호", 
					dataField : "process_no", 
					width : "120",
					minWidth : "120",
					style : "aui-center",
// 					labelFunction : function(rowIndex, columnIndex, value) {
// 						return value.substring(value.length, value.length-4);
// 					},
				},
				{ 
					headerText : "우편번호", 
					dataField : "post_no",
					visible : false
				},
				{ 
					headerText : "주소1", 
					dataField : "addr1",
					visible : false
				},
				{ 
					headerText : "주소2", 
					dataField : "addr2", 
					visible : false
				},
				{ 
					headerText : "전화번호", 
					dataField : "receive_tel_no", 
					visible : false
				},
				{ 
					headerText : "송장비용방식코드", 
					dataField : "invoice_money_cd", 
					visible : false
				},
				{ 
					headerText : "송장발송구분코드", 
					dataField : "invoice_send_cd", 
					visible : false
				},
				{ 
					headerText : "주소", 
					dataField : "addr", 
					minWidth : "300",
					style : "aui-left"
				},
				{ 
					headerText : "고객명", 
					dataField : "receive_name", 
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{ 
					headerText : "핸드폰", 
					dataField : "receive_hp_no", 
					width : "120",
					minWidth : "120",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     if(String(value).length > 0) {
					         // 전화번호에 대시 붙이는 정규식으로 표현
					         return value.replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]+)([0-9]{4})/,"$1-$2-$3"); 
					     }
					     return value; 
					}
				},
				{ 
					headerText : "참고", 
					dataField : "remark", 
					width : "120",
					minWidth : "120",
					style : "aui-left"
				},
				{ 
					headerText : "주소변경", 
					dataField : "changeBtn", 
					width : "55",
					minWidth : "55",
					style : "aui-right",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							fnInit();
							var param = {
									receive_name : event.item["receive_name"],
									post_no : event.item["post_no"],
									addr1 : event.item["addr1"],
									addr2 : event.item["addr2"],
									remark : event.item["remark"],
									receive_hp_no : $M.phoneFormat(event.item["receive_hp_no"]),
									receive_tel_no : event.item["receive_tel_no"],
									invoice_money_cd : event.item["invoice_money_cd"],
									invoice_send_cd : event.item["invoice_send_cd"],
							}
							$M.setValue(param);
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '적용'
					},
				}
				
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${sendList});
			$("#auiGrid").resize();
		}
		//그리드생성
		function createAUIGridBottom() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
			};
			var columnLayout = [
				{
					dataField : "seq_no",
					visible : false,
				},
				{
					headerText : "구분",
					dataField : "base_yn",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						if(value == "Y"){
							return '기본'
						}
						return ''
					},
				},
				{
					headerText : "수령인",
					dataField : "receive_name",
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{
					headerText : "핸드폰",
					dataField : "receive_hp_no",
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{
					headerText : "전화번호",
					dataField : "receive_tel_no",
					width : "120",
					minWidth : "120",
					style : "aui-center"
				},
				{
					headerText : "배송지",
					dataField : "addr",
					minWidth : "300",
					style : "aui-left"
				},

			];
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridBottom, ${addrList});
			$("#auiGrid").resize();
		}
		function fnInit() {
			var param = {
					receive_name : "",
					post_no : "",
					addr1 : "",
					addr2 : "",
					remark : "",
					receive_hp_no : "",
					receive_tel_no : "",
					qty : "",
					invoice_no : "",
			}
			$M.setValue(param);
		}
		
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			};
			
			var param = {
					invoice_send_cd : $M.getValue("invoice_send_cd"),
					receive_name : $M.getValue("receive_name"),
					receive_hp_no : $M.getValue("receive_hp_no"),
					receive_tel_no : $M.getValue("receive_tel_no"),
					invoice_no : $M.getValue("invoice_no"),
					bill_no : $M.getValue("invoice_no"),
					invoice_qty : $M.getValue("qty"),
					invoice_money_cd : $M.getValue("invoice_money_cd"),
					invoice_remark : $M.getValue("remark"),
					invoice_post_no : $M.getValue("post_no"),
					invoice_addr1 : $M.getValue("addr1"),
					invoice_addr2 : $M.getValue("addr2")
			}
			
			opener.setDeliveryInfo(param);
			fnClose();	
		}
		
		   // 문자발송
		function fnSendSms() {
			  var param = {
					  name : $M.getValue("receive_name"),
					  hp_no : $M.getValue("receive_hp_no")
			  }
			  	openSendSmsPanel($M.toGetParam(param));
		}
		   
		// 닫기
		function fnClose() {
			window.close();
		}
		
		// 주소팝업
		function fnJusoBiz(data) {
			$M.setValue("post_no", data.zipNo);
			$M.setValue("addr1", data.roadAddrPart1);
			$M.setValue("addr2", data.addrDetail);
		}
		
		// 대신화물 배송추적
		function goDeliveryTracking(){
			var billNo = $M.getValue("invoice_no");
			if(billNo == "" || billNo == null){
				alert("송장번호가 없습니다.");
				return false;
			}
			var param = {
				bill_no : billNo,
			};

			var poppupOption = "";
			$M.goNextPage('/cust/cust0201p09', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		// 대신화물 수동매칭
		function goMapping(){
			param = {
				parent_js_name : "fnSetDsInvoice"
			};

			var poppupOption = "";
			$M.goNextPage('/cust/cust0201p08', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
        function fnSetDsInvoice(row){
            var frm = document.main_form;
            $M.setValue(frm, "invoice_no", row.bill_no);
            $M.setValue(frm, "bill_no", row.bill_no); // 대신화물 송장번호
            $M.setValue(frm, "qty", row.qty);
            
        }
        
		function fnPrint() {
			
			var invoiceCheckedId = $("input[name='invoice_money_cd']:checked").attr("id");
			var invoiceMoneyName = "발송구분: " + $("label[for='"+invoiceCheckedId+"']").text();
			
			var invoiceSendName = $("#invoice_send_cd option:selected").text();
			
			var data = {
				"receive_name" : $M.getValue("receive_name")
				, "receive_hp_no" : $M.getValue("receive_hp_no")
				, "receive_tel_no" : $M.getValue("receive_tel_no")
				, "addr1" : $M.getValue("addr1")
				, "addr2" : $M.getValue("addr2")
				, "remark" : "배송시 요청사항:" + $M.getValue("remark")
				, "invoice_money_name" : invoiceMoneyName
				, "invoice_send_name" : invoiceSendName
			};
			
			var param = {
				"data" : data
// 				, "apprData" : apprList
			}
			
			openReportPanel('cust/cust0201p01_01.crf', param);
			
		}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 상단 폼테이블 -->					
			<div>
				<div class="text-right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div class="title-wrap">
					<h4>배송정보설정</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">배송구분</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<select class="form-control width100px essential-bg" id="invoice_send_cd" name="invoice_send_cd" required="required" alt="배송구분">
											<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
												<option value="${item.code_value}" ${item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
											</c:forEach>
										</select>
									</div>
									<div class="col-7">
										<c:forEach items="${codeMap['INVOICE_MONEY']}" var="item">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="invoice_money_cd" id="invoice_money_cd${item.code_value}" value="${item.code_value}" required="required" alt="선불과 착불 중 하나" checked>
												<label class="form-check-label" for="invoice_money_cd${item.code_value}">${item.code_name}</label>
											</div>
										</c:forEach>
									</div>
								</div>
							</td>	
							<th class="text-right essential-item">수령인</th>
							<td>
								<input type="text" class="form-control width120px essential-bg" id="receive_name" name="receive_name" value="" required="required" alt="수령인">
							</td>													
						</tr>
						<tr>
<%--							<th class="text-right">송장</th>--%>
							<th class="text-right">대신화물송장</th>
							<td>
<%--							<input type="text" class="form-control width120px" id="invoice_no" name="invoice_no">--%>
								<div class="form-row inline-pd">
									<div class="col-4">
										<input type="text" class="form-control width120px" id="invoice_no" name="invoice_no" readonly="readonly">
									</div>
									<div class="col-8">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
									</div>
								</div>
							</td>
							<th class="text-right">휴대폰</th>
<%--							<th class="text-right">전화번호</th>--%>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width140px" id="receive_hp_no" name="receive_hp_no" value="">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>	
								</div>
<%--								<input type="text" class="form-control width140px" id="receive_tel_no" name="receive_tel_no" value="">--%>
							</td>									
						</tr>
						<tr>
							<th class="text-right essential-item">수량</th>
							<td>
								<input type="text" class="form-control text-right width60px" id="qty" name="qty" alt="수량" format="decimal" readonly="readonly">
							</td>
							<th class="text-right">전화번호</th>
<%--							<th class="text-right">배송 시 요청사항</th>--%>
							<td>
								<input type="text" class="form-control width140px" id="receive_tel_no" name="receive_tel_no" value="" maxlength="45">
<%--								<input type="text" class="form-control" id="remark" name="remark" value="" maxlength="45">--%>
							</td>									
						</tr>
						<tr>
<%--							<th class="text-right essential-item">구분</th>--%>
<%--							<td>--%>
<%--								<div class="form-check form-check-inline">--%>
<%--									<input class="form-check-input" type="radio" name="invoice_money_cd" id="invoice_money_cd1" value="1" required="required" alt="구분" checked>--%>
<%--									<label class="form-check-label" for="invoice_money_cd1">착불</label>--%>
<%--								</div>--%>
<%--								<div class="form-check form-check-inline">--%>
<%--									<input class="form-check-input" type="radio" name="invoice_money_cd" id="invoice_money_cd0" value="0" required="required" alt="구분">--%>
<%--									<label class="form-check-label" for="invoice_money_cd0">선불</label>--%>
<%--								</div>--%>
<%--								<div class="form-check form-check-inline">--%>
<%--									<input class="form-check-input" type="radio" name="invoice_money_cd" id="invoice_money_cd2" value="2" required="required" alt="구분">--%>
<%--									<label class="form-check-label" for="invoice_money_cd2">발신</label>--%>
<%--								</div>--%>
<%--								<div class="form-check form-check-inline">--%>
<%--									<input class="form-check-input" type="radio" name="invoice_money_cd" id="invoice_money_cd3" value="3" required="required" alt="구분">--%>
<%--									<label class="form-check-label" for="invoice_money_cd3">착신</label>--%>
<%--								</div>--%>
<%--							</td>--%>
							<th class="text-right">배송시요청사항</th>
							<td colspan="3">
								<input type="text" class="form-control" id="remark" name="remark">
							</td>									
						</tr>			
						<tr>								
							<th class="text-right">배송지</th>
							<td colspan="3">
								<div class="form-row inline-pd mb7">
									<div class="col-1">
										<input type="text" class="form-control" id="post_no" name="post_no" value="" readonly="readonly">
									</div>
									<div class="col-11">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnJusoBiz');" >주소찾기</button>
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-6">
										<input type="text" class="form-control" id="addr1" name="addr1" value="">
									</div>
									<div class="col-6">
										<input type="text" class="form-control" id="addr2" name="addr2" value="">
									</div>
								</div>
								<div class="form-row inline-pd">
									
								</div>
							</td>
						</tr>													
					</tbody>
				</table>
			</div>
<!-- /상단 폼테이블 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4>이전발송지</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 180px;"></div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4>고객등록배송지</h4>
			</div>
			<div id="auiGridBottom" style="margin-top: 5px; height: 180px;"></div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>