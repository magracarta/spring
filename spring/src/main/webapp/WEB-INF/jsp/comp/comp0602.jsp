<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 부품연관팝업 > 부품연관팝업 > null > 부품발주요청등록
-- 작성자 : 김태훈, 강명지
-- 최초 작성일 : 2020-02-05 16:47:04, 2020-02-19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			// TODO: 조직코드가 센터코드와 맞지 않아서 주석
			//$M.setValue("order_org_code", '${SecureUser.org_code}');
		
			fnInit();
		});
		
		function fnInit() {
			if("${inputParam.part_no}" != "") {
				$M.setValue("part_no", "${inputParam.part_no}");
				fnSearchPart();
			}
		}
		 
		// 부품요청 저장
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm, {field:['part_no', 'part_preorder_type_cd', 'part_name', 'order_qty']}) == false) {
				return;
			}
			if($M.getValue("order_org_code") == ""){
				alert("사업부를 다시 확인해주세요.");
				return false;
			}
			if ($M.getValue("order_qty") <= 0){
				alert("요청 수량을 다시 확인해주세요.");
				return false;
			}
			
			// 이미 발주중인 발주요청인지 조회
			$M.goNextPageAjax(this_page+"/checkPart", $M.toValueForm(frm), { method : "GET", loader : false},
					function(result) {
						if(result.success) {
							// 발주요청된 자료일 경우 정말로 등록할것인지 다시 확인함
							if (result.request_order_qty) {
								if (confirm(result.part_no+"(수량:"+result.request_order_qty+")은 이미 발주요청에 등록되어 있습니다.\n계속 등록하려면 확인, 다른 부품을 등록하려면 취소를 선택하십시오.") == false) {
									return false;
								} else {
									goAfterSave(frm);
								}	
							} else {
								// 발주요청된 자료가 아니면 그냥 저장
								goAfterSave(frm);
							}
						} 
					}
				);
		}
		
		function goAfterSave(frm) {
			$M.goNextPageAjaxSave(this_page, $M.toValueForm(frm), { method : "POST"},
					function(result) {
						if(result.success) {
							var returnObj = {
								"part_no" : $M.getValue("part_no"),
								"order_org_code" : $M.getValue("order_org_code"),
								"part_preorder_type_cd" : $M.getValue("part_preorder_type_cd"),
								"order_qty" : $M.getValue("order_qty"),
							}
							alert("발주요청 처리되었습니다.");
							opener.${inputParam.parent_js_name}(returnObj);
							fnClose();
						} 
					}
				);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["part_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					fnSearchPart();
				};
			});
		}
		
		function fnClose() {
			window.close();
		}
		
		// 고객팝업 클릭 후 리턴
		function fnSetCustInfo(row) {
			$M.getValue("cust_name") != "" ? "" : $("#clear-btn").toggleClass("dpn"); 
			$M.setValue("cust_name", row.cust_name);
			$M.setValue("order_cust_no", row.cust_no);
		}
		
		// 부품팝업 클릭 후 리턴
		function fnSetPartInfo(row) {
			console.log(row);
			isChanged = false;
			$M.setValue("part_no", row.part_no);
			$M.setValue("part_name", row.part_name);
			$M.setValue("in_qty", row.part_current);
		}
		
		function fnClearCustInfo() {
			$("#clear-btn").toggleClass("dpn");
			$M.setValue("cust_name", null);
			$M.setValue("order_cust_no", null);
		}
		
		// 부품조회(단일)
      function fnSearchPart() {
    	  var param = {
    			 's_part_no' : $M.getValue('part_no'),
    			 's_req_yn' : "Y",
			     'use_type' : "part_order" // 2022.10.19 15267 부품발주요청 시 비부품은 발주요청되지 않도록 수정
    	  };
    	  openSearchPartPanel('fnSetPartInfo', 'N', $M.toGetParam(param));
      }
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
       <div class="main-title">
       	<h2>부품발주요청</h2>
       </div>
<!-- /타이틀영역 -->
       <div class="content-wrap">	
<!-- 폼테이블 -->					
		<div>
			<table class="table-border">
				<colgroup>
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right essential-item">발주구분</th>
						<td>
							<c:forEach var="item" items="${codeMap['PART_PREORDER_TYPE']}" varStatus="status">
								<div class="form-check form-check-inline">
									<c:if test="${status.first}">
										<input class="form-check-input" type="radio" value="${item.code_value}" checked="checked" id="${item.code_value}" name="part_preorder_type_cd">
									</c:if>
									<c:if test="${!status.first}">
										<input class="form-check-input" type="radio" id="${item.code_value}" name="part_preorder_type_cd" value="${item.code_value}" <c:if test="${list.part_preorder_status_cd eq item.code_value}">checked="checked"</c:if>>
									</c:if>
									<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
								</div>
							</c:forEach>
						</td>						
					</tr>
					<tr>
						<th class="text-right essential-item">부품번호</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0 essential-bg width120px" id="part_no" name="part_no" alt="부품번호" <c:if test='${!empty list.part_no}'> value= '${list.part_no}' </c:if>>
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchPart();"><i class="material-iconssearch"></i></button>
							</div>
						</td>						
					</tr>	
					<tr>
						<th class="text-right essential-item">부품명</th>
						<td>
							<input type="text" class="form-control" readonly="readonly" id="part_name" name="part_name" alt="부품명" <c:if test='${!empty list.part_name}'> value= '${list.part_name}' </c:if>>
						</td>						
					</tr>
					<tr>
						<th class="text-right">현재고</th>
						<td>
							<input type="text" class="form-control text-right width120px" readonly="readonly" id="in_qty" name="in_qty" alt="현재고" <c:if test='${!empty list.in_qty}'> value= '${list.in_qty}' </c:if>>
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">요청수량</th>
						<td>
							<input type="text" class="form-control text-right width120px" id="order_qty" name="order_qty" format="num" min="1" alt="요청수량" <c:if test='${!empty list.request_order_qty}'> value= '${list.request_order_qty}' </c:if>>
						</td>
					</tr>
					<tr>
						<th class="text-right">요청처</th>
						<td>
							<div class="form-row inline-pd mb7">
								<div class="col-3 text-right">
									<div class="form-check form-check-inline" style="margin-right: 0px !important;">
										<label class="form-check-label  essential-item">사업부</label>
									</div>
								</div>
								<div class="col-9">
									<input type="text" class="form-control border-right-0" style="width: 100%;"
											<c:if test='${!empty list.order_org_code}'> value= '${list.order_org_code}' </c:if>   
											<c:if test='${empty list.order_org_code}'> value= '${SecureUser.org_code}' </c:if>
											id="order_org_code"
											name="order_org_code" 
											idfield="code_value"
											textfield="code_name"
											easyui="combogrid"
											header="Y"
											easyuiname="centerList" 
											panelwidth="200"
											maxheight="155"
											multi="N"/>
								</div>								
							</div>
							<div class="form-row inline-pd">
								<div class="col-3 text-right" >
									<div class="form-check form-check-inline" style="margin-right: 0px !important;">
										<!-- <input class="form-check-input" type="radio" style="visibility: hidden;">  --><!-- 영역고정용 -->
										<label class="form-check-label">고객</label>
									</div>
								</div>
								<div class="col-9">
									<div class="input-group">
										<div class="icon-btn-cancel-wrap " style="width : calc(100% - 24px);">
										<input type="text" class="form-control border-right-0" alt="" readonly="readonly" id="cust_name" name="cust_name" <c:if test='${!empty list.cust_name}'> value= '${list.cust_name}' </c:if>>
											<button type="button" class="icon-btn-cancel dpn" style="top: 50%;transform: translateY(-50%); margin-top: -1px;" onclick="fnClearCustInfo()" id="clear-btn"><i class="material-iconsclose font-16 text-default"></i></button>
										</div>
										<button type="button" class="btn btn-icon btn-primary-gra" style="    border-radius: 0px 4px 4px 0;" onclick="javascript:openSearchCustPanel('fnSetCustInfo')"><i class="material-iconssearch"></i></button>
									</div>
								</div>								
							</div>
							
						</td>
					</tr>
					<tr>
						<th class="text-right">비고</th>
						<td>
							<textarea class="form-control" style="height: 100px;" id="memo" name="memo"><c:if test='${!empty list.memo}'><c:out value="${list.memo}"/></c:if></textarea>
						</td>
					</tr>					
				</tbody>
			</table>
		</div>
<!-- /폼테이블 -->	

<!-- 그리드 서머리, 컨트롤 영역 -->
		<div class="btn-group mt5">						
			<div class="right">
				<button type="button" class="btn btn-info" onclick="javascript:goSave();">발주요청</button>
				<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
			</div>
		</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
       </div>
   </div>
<input type="hidden" class="form-control" alt="" id="order_cust_no" name="order_cust_no">
</form>
</body>
</html>