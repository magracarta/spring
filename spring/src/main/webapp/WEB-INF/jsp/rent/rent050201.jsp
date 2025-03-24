<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 이동/재렌탈 > 센터 간 이동 > 이동신청 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var centerAddr;
		
		$(document).ready(function () {
			createAUIGridTrans();
			createAUIGrid();
			fnInit();
		});
		
		function fnInit() {
			try {
			  if("${rent.reduce_yn}" == "Y")
			  $($("#menu_navi").children()[1]).html("이동(판매)신청");
			} catch(e) {
				
			}
			centerAddr = new Object();
			var firstCd = "";
			<c:forEach items="${center}" var="item" varStatus="status">
			if ("${item.org_code}" != "") {
				<c:if test="${item.org_code eq SecureUser.org_code}">firstCd = "${item.org_code}"</c:if>
				centerAddr["${item.org_code}"] = ["${item.post_no}", "${item.addr1}"];
			}
			</c:forEach>
			if (firstCd == "") {
				firstCd = $M.getValue("to_org_code");
			}
			$M.setValue("delivery_post_no", centerAddr[firstCd][0]);
			$M.setValue("delivery_addr1", centerAddr[firstCd][1]);
			if("${rent.reduce_yn}" == "Y") {
				getAttachPrice();				
			} else {
				fnCalc();
			}
		}
		
		function fnChangeOutOrgCode() {
			var cd = $M.getValue("to_org_code");
			if (cd != "") {
				$M.setValue("delivery_post_no", centerAddr[cd][0]);
				$M.setValue("delivery_addr1", centerAddr[cd][1]);
			}

			// 요청센터 변경시 관리센터도 같이 변경
			$M.setValue("to_mng_org_code", cd);
		}
		
		function fnChangeDeliveryCd() {
			var cd = $M.getValue("rental_delivery_cd");
			if (cd == "01") {
				$(".dc *").attr("disabled", true);  
			} else {
				$(".dc *").attr("disabled", false);
				//fnChangeOutOrgCode();
			}
		}
		
		//그리드생성
		function createAUIGridTrans() {
			var gridPros = {
				showRowNumColumn: true
			};
			var columnLayout = [
				/* { 
					headerText : "요청번호", 
					dataField : "rental_trans_no", 
				}, */
				{ 
					headerText : "이동처리일", 
					dataField : "trans_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "소유센터(FROM)", 
					dataField : "from_org_name", 
					style : "aui-center"
				},
				{ 
					headerText : "요청센터(TO)", 
					dataField : "to_org_name", 
					style : "aui-center"
				},
				{ 
					headerText : "요청자", 
					dataField : "receipt_mem_name",
					style : "aui-center"
				}
			];
			
			auiGridTrans = AUIGrid.create("#auiGridTrans", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridTrans, ${trans});
			$("#auiGridTrans").resize();
		}
		
		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColum : true
			};
	
			var columnLayout = [
				{
					headerText : "어태치먼트명",
					dataField : "attach_name",
					style : "aui-left",
				},
				{
					headerText : "적용장비",
					dataField : "machine_name",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return $M.getValue("machine_name")
					},
					width : "20%"
				},
				{
					headerText : "일련번호",
					dataField : "product_no",
					style : "aui-center",
					width : "12%"
				},
				{
					headerText : "모델명",
					dataField : "part_no",
					style : "aui-center",
					width : "12%"
				},
				{
					headerText : "제조사",
					dataField : "client_name",
					style : "aui-center",
					width : "13%",
				},
				{
					headerText : "관리번호",
					dataField : "rental_attach_no",
					style : "aui-center",
					width : "13%",
				},
				{
					headerText : "삭제",
					dataField : "h",
					width : "9%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.removeSoftRows(auiGrid);
							if("${rent.reduce_yn}" == "Y") {
								getAttachPrice();				
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
				},
				{
					dataField : "min_sale_price",
					visible : false
				},
				{
					dataField : "cost_yn",
					visible : false
				},
				{
					dataField : "base_yn",
					visible : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${attach});
		}
		
		//어태치먼트추가
		function goAttachPopup() {
			var rows = AUIGrid.getGridData(auiGrid);
			// 2020-08-10 회의
			// 이동, 재렌탈는 소유센터의  어태치만 조회
			// 고객렌탈일떄는 관리센터의 어태치만 조회
	     	var params = {
	     		rental_machine_no : $M.getValue("rental_machine_no"),
     			own_org_code : "${rent.own_org_code}",
	     		not_rental_attach_no : $M.getArrStr(rows, {key : 'rental_attach_no'})
	     	};
	     	openRentalAttachPanel("fnSetAttach", $M.toGetParam(params))
	    }
		
		function fnSetAttach(row) {
			var item = new Object();
			if(row != null) {
				for(i=0; i<row.length; i++) {
					item.part_name = row[i].part_name;
					item.part_no = row[i].part_no;
					item.attach_name = row[i].attach_name;
					item.qty = 1;
					item.product_no = row[i].product_no;
					item.client_name = row[i].client_name;
					item.min_sale_price = row[i].min_sale_price;
					item.rental_attach_no = row[i].rental_attach_no;
					item.cost_yn = row[i].cost_yn;
					item.base_yn = row[i].base_yn;
					AUIGrid.addRow(auiGrid, item, 'last');
				}
				if("${rent.reduce_yn}" == "Y") {
					getAttachPrice();				
				}
			}
			AUIGrid.resize(auiGrid);
		}
		
		function getAttachPrice() {
			var attach_price = 0;
			var grid = AUIGrid.getGridData(auiGrid);
			for (var i = 0; i < grid.length; ++i) {
				var isRemoved = AUIGrid.isRemovedById(auiGrid, grid[i]._$uid);
				if (!isRemoved) {
					attach_price+=$M.toNum(grid[i].min_sale_price)
				}
			}
			$M.setValue("attach_price", attach_price);
			fnCalc();
		}
	   
	   function fnCalc() {
		  
		  var machine_price = $M.toNum($M.getValue("machine_price"));
		  var min_sale_price = $M.toNum($M.getValue("min_sale_price"));
		  var attach_price = $M.toNum($M.getValue("attach_price"));
		  var sale_price = $M.toNum($M.getValue("sale_price"));
		  
		  if (sale_price > machine_price) {
			  alert("장비가액을 초과할 수 없습니다.");
			  sale_price = machine_price;
		  }
		  
		  var from_balance_price = sale_price;
		  var to_balance_price = machine_price - sale_price;
		  
		  var param = {
				machine_price : machine_price,
				attach_price : attach_price,
				sale_price : sale_price,
				from_balance_price : from_balance_price,
				to_balance_price : to_balance_price
		  }
		  $M.setValue(param);
	   }
		
		//결재요청버튼
		function goRequestApproval() {
			goSave('appr');
		}
		
		//저장버튼
		function goSave(appr) {
			var frm = document.main_form;
			if ($M.validation(frm) == false) { 
				return false;
			}
			if ($M.getValue("rental_delivery_cd") != "01") {
				// (Q&A 13379) 울산센터 post_no가 없음., 이동처리시 필요하지 않아서 주석처리함. (post_no 있어도 저장하고 있지도 않음.)
// 				if ($M.validation(frm, {field : ['delivery_post_no']}) == false) {
// 					return false;					
// 				}
			}
			// if ($M.getValue("to_org_code") == $M.getValue("from_org_code")) {
			// 	alert("요청센터를 다시 확인해주세요.");
			// 	$("#to_org_code").focus();
			// 	return false;
			// }
			var salePrice = $M.toNum($M.getValue("sale_price"));
			var minSalePrice = $M.toNum($M.getValue("min_sale_price"));
			if (salePrice < minSalePrice) {
				alert("판매최소금액 "+$M.setComma(minSalePrice)+"원 보다 커야합니다.");
				return false;
			}
			if ($M.toNum($M.getValue("sale_price")) > $M.toNum($M.getValue("machine_price"))) {
				alert("장비가액을 초과할 수 없습니다.");
				return false;
			}
			var msg = appr == "appr" ? "결재요청하시겠습니까?" : "저장하시겠습니까?";
			
			var frm = $M.toValueForm(frm);
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			var gridForm = fnGridDataToForm(concatCols, concatList);
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);
			appr = appr == undefined ? "save" : appr;
			console.log(appr);
			$M.setValue("save_mode", appr);
			$M.setValue("to_org_code", $M.getValue("to_org_code"));
			$M.goNextPageAjaxMsg(msg, this_page, gridForm, {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			alert("처리가 완료되었습니다.");
			    			fnList();
						}
					}
				);
		}
		
		// 주소결과
		function fnSetAddr(row) {
			var param = {
				delivery_post_no : row.zipNo
				, delivery_addr1 : row.roadAddr
				, delivery_addr2 : row.addrDetail
			}
			$M.setValue(param);
		}
		
		//렌탈장비대장버튼
		function goEquipment() {
			var params = {
				rental_machine_no : "${rent.rental_machine_no}"	
			};
	     	var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=520, left=0, top=0";
			$M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		//수리이력버튼
		function goRepairHistory() {
			var params = {
		     	s_machine_seq : "${rent.machine_seq}"
		    };
		   	var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		//목록버튼
		function fnList() {
			$M.goNextPage("/rent/rent0502");
		}

		// 업무DB 연결 함수 21-08-05이강원
     	function openWorkDB(){
     		openWorkDBPanel('', ${rent.machine_plant_seq});
     	}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="from_org_code" name="from_org_code" value="${rent.own_org_code}">
<input type="hidden" id="from_mng_org_code" name="from_mng_org_code" value="${rent.mng_org_code}">
<input type="hidden" id="reduce_yn" name="reduce_yn" value="${rent.reduce_yn }">
<input type="hidden" id="save_mode" name="save_mode">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
<!-- 상세페이지 타이틀 -->
			<div class="main-title detail">
				<div class="detail-left approval-left" style="align-items: center;">
					<div class="left" id="menu_navi">
						<button type="button" onclick="fnList()" class="btn btn-outline-light"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						<div style="min-width:80px; margin-top: auto; margin-bottom: auto; margin-right: 10px;">
							<span class="condition-item">상태 : 작성중</span>
						</div>
					</div>
				</div>
<!-- 결재영역 -->
				<div class="pl10">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->
			</div>
<!-- /상세페이지 타이틀 -->
			<div class="contents">			
				<div>
<!-- 폼테이블 1 -->				
					<table class="table-border">
						<colgroup>
							<col width="120px">
							<col width="">
							<col width="120px">
							<col width="">
							<col width="120px">
							<col width="160px">
							<col width="120px">
							<col width="160px">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">관리번호</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<input type="text" class="form-control width170px" readonly="readonly" id="rental_machine_no" name="rental_machine_no" value="${rent.rental_machine_no}">
										</div>
									</div>
								</td>	
								<th class="text-right rs">요청일</th>
								<td>
									<div class="input-group width120px">
										<input type="text" class="form-control border-right-0 rb calDate" id="trans_dt" name="trans_dt" value="${inputParam.s_current_dt}" dateFormat="yyyy-MM-dd" alt="요청일">
									</div>
								</td>
								<th class="text-right">기존 소유센터</th>
								<td>
									<input type="text" class="form-control width120px" readonly="readonly" value="${rent.own_org_name}">
								</td>
								<th class="text-right">기존 관리센터</th>
								<td>
									<input type="text" class="form-control width120px" readonly="readonly" value="${rent.mng_org_name}">
								</td>
							</tr>
							<tr>
								<th class="text-right">메이커</th>
								<td>
									<input type="text" class="form-control width120px" readonly="readonly" value="${rent.maker_name}">				
								</td>	
								<th class="text-right">모델명</th>
								<td>
									<div class="form-row inline-pd pr">
    									<div class="col-auto">
											<input type="text" class="form-control width120px" readonly="readonly" value="${rent.machine_name}" id="machine_name" name="machine_name">		
										</div>
									    <div class="col-auto">
									        <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
									    </div>
									</div>
								</td>
								<th class="text-right rs">변경소유센터</th>
								<td>
									<select class="form-control rb width120px" id="to_org_code" name="to_org_code" alt="소유센터" onchange="fnChangeOutOrgCode()" ${page.fnc.F00994_001 eq 'Y' ? 'disabled' : ''}>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code }">selected</c:if>>${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th class="text-right rs">변경관리센터</th>
								<td>
									<select class="form-control rb width120px" id="to_mng_org_code" name="to_mng_org_code" alt="관리센터" ${page.fnc.F00994_001 eq 'Y' ? 'disabled' : ''}>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code }">selected</c:if>>${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<th class="text-right">연식</th>
								<td>
									<input type="text" class="form-control width50px" readonly="readonly" value="${fn:substring(rent.made_dt,0,4)}">					
								</td>										
								<th class="text-right">가동시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" class="form-control" readonly="readonly" value="${rent.op_hour}" format="decimal">
										</div>
										<div class="col width33px">
											hr
										</div>
									</div>		
								</td>	
								<th class="text-right">이동처리일자</th>
								<td colspan="3">
									<input type="text" class="form-control width120px" readonly="readonly">				
								</td>
							</tr>
							<tr>
								<th class="text-right">차대번호</th>
								<td>
									<input type="text" class="form-control width240px" readonly="readonly" value="${rent.body_no }">				
								</td>	
								<th class="text-right">GPS정보</th>
								<td>
									<c:choose>
										<c:when test="${not empty rent.sar }">
											<span class="underline" onclick="javascript:window.open('https://terra.smartassist.yanmar.com/machine-operation/map')">SA-R</span>
										</c:when>
										<c:otherwise>
											<input type="hidden" id="gps_seq" name="gps_seq" value="${rent.gps_seq}" >
											<div class="form-row inline-pd widthfix">
												<div class="col width33px text-right">
													종류
												</div>
												<div class="col width60px">
													<select class="form-control" id="gps_type_cd" name="gps_type_cd" disabled="disabled">
														<option value="">- 선택 -</option>
														<c:forEach items="${codeMap['GPS_TYPE']}" var="codeitem">
															<option value="${codeitem.code_value}" ${rent.gps_type_cd eq codeitem.code_value ? 'selected="selected"' : ''}>${codeitem.code_name}</option>
														</c:forEach>
													</select>
												</div>
												<div class="col width55px text-right">
													개통번호
												</div>
												<div class="col width100px">
													<input type="text" class="form-control underline" readonly="readonly" id="gps_no" name="gps_no" value="${rent.gps_no}" onclick="javascript:window.open('http://s1.u-vis.com')">
												</div>
											</div>
										</c:otherwise>
									</c:choose>
								</td>
								<th class="text-right">요청자</th>
								<td colspan="3">
									<input type="text" class="form-control width120px" readonly="readonly" value="${SecureUser.kor_name}">
								</td>
							</tr>
						</tbody>
					</table>
<!-- 폼테이블 1 -->	
					<%-- <div class="title-wrap mt10">
						<div class="left">
							<h4>이동신청정보</h4>
							<span style="padding-left : 5px; color: red;">정산가격은 판매최소금액(<fmt:formatNumber value="${rent.min_sale_price}"></fmt:formatNumber>)원 보다 크고 장비가액보다는 작아야 합니다.</span>
						</div>
						<div class="right">
							<button type="button" class="btn btn-default" onclick="javascript:goEquipment()">렌탈장비대장</button>
							<button type="button" class="btn btn-default" onclick="javascript:goRepairHistory()">수리이력</button>
						</div>
					</div>
					<table class="table-border mt5">
							<colgroup>
								<col width="120px">
								<col width="">
								<col width="140px">
								<col width="">
								<col width="140px">
								<col width="">
							</colgroup>
							<tbody>
								<c:if test="${rent.reduce_yn eq 'Y'}">
								<tr>
									<th class="text-right rs">정산가격(판매)</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right rb" id="sale_price" name="sale_price" format="decimal" onchange="fnCalc()" required="required">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
									<th class="text-right">어태치가격</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" readonly="readonly" id="attach_price" name="attach_price" format="decimal">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
									<th class="text-right">장비가액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" readonly="readonly" id="machine_price" name="machine_price" format="decimal" value="${rent.machine_price }">
												<input type="hidden" id="min_sale_price" name="min_sale_price" value="${rent.min_sale_price}">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">중고시세가</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" readonly="readonly" id="used_machine_price" name="used_machine_price" format="decimal" value="${rent.used_price }">
											</div> 
											<div class="col width16px">원</div>
										</div>
									</td>
									<th class="text-right">정산 매입가(구매센터)</th> <!-- 렌탈 기획서 46p 코멘트에 따라 명칭을 정산잔액(신청센터)에서 정산 매입가 (구매센터) 로 변경합니다. -->
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" readonly="readonly" id="to_balance_price" name="to_balance_price" format="decimal">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
									<th class="text-right">정산 매도가(판매센터)</th> <!-- 렌탈 기획서 46p 코멘트에 따라 명칭을 정산잔액(이동센터)에서 정산 매도가 (판매센터) 로 변경합니다. -->
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" readonly="readonly" id="from_balance_price" name="from_balance_price" format="decimal">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>
								</c:if>
								<tr>
									<th class="text-right rs">인도방법</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<select class="form-control rb" id="rental_delivery_cd" name="rental_delivery_cd" alt="인도방법" required="required" onchange="fnChangeDeliveryCd()">
													<option value="">- 선택 -</option>
													<c:forEach var="item" items="${codeMap['RENTAL_DELIVERY']}">
														<option value="${item.code_value}">${item.code_name}</option>
													</c:forEach>
												</select>
											</div>
											<div class="col width120px">
												<div class="form-check form-check-inline dc">
													<input class="form-check-input" type="radio" checked="checked" value="O" name="delivery_type_ot" id="delivery_type_ot_o">
													<label class="form-check-label" for="delivery_type_ot_o">편도</label>
												</div>
												<div class="form-check form-check-inline dc">
													<input class="form-check-input" type="radio" value="T" name="delivery_type_ot" id="delivery_type_ot_t">
													<label class="form-check-label" for="delivery_type_ot_t">왕복</label>
												</div>
											</div>
										</div>
									</td>
									<th class="text-right">운송구분(신청자기준)</th>
									<td>
										<div class="form-check form-check-inline dc">
											<input class="form-check-input" type="radio" checked="checked" value="P" name="delivery_pay_type_pl" id="delivery_pay_type_pl_p">
											<label class="form-check-label" for="delivery_pay_type_pl_p">선불</label>
										</div>
										<div class="form-check form-check-inline dc">
											<input class="form-check-input" type="radio" value="L" name="delivery_pay_type_pl" id="delivery_pay_type_pl_l">
											<label class="form-check-label" for="delivery_pay_type_pl_l">착불</label>
										</div>
									</td>
									<th class="text-right">운송료</th>
									<td>
										<div class="form-row inline-pd widthfix dc">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="decimal" id="delivery_amt" name="delivery_amt" alt="운송료" format="decimal">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>								
								<tr>
									<th class="text-right">배송지</th>
									<td colspan="5">
                                    <div class="form-row inline-pd dc">
                                        <div class="col-1 pdr0">
                                            <input type="text" class="form-control mw45" readonly="readonly"
                                                   id="delivery_post_no" name="delivery_post_no"
                                                   alt="우편번호">
                                        </div>
                                        <div class="col-auto pdl5">
                                            <button type="button" class="btn btn-primary-gra full dc" id="btnAddr"
                                                    onclick="javascript:openSearchAddrPanel('fnSetAddr');">주소찾기
                                            </button>
                                        </div>
                                        <div class="col-5">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   id="delivery_addr1" name="delivery_addr1"
                                                   alt="주소">
                                        </div>
                                        <div class="col-4">
                                            <input type="text" class="form-control"
                                                   id="delivery_addr2" name="delivery_addr2" alt="상세 주소" maxlength="75">
                                        </div>
                                    </div>
                                </td>
								</tr>
								<tr>
									<th class="text-right">비고</th>
									<td colspan="5">
										<textarea class="form-control" style="height: 70px;" id="remark" name="remark" maxlength="50"></textarea>						
									</td>
								</tr>							
							</tbody>
						</table> --%>
					<div class="row">
						<div class="col-7">
<!-- 어태치먼트 구성 -->
							<div class="title-wrap mt10">
								<div class="left">
									<h4>어태치먼트 구성</h4>
								</div>
								<div class="right">
									<button type="button" onclick="goAttachPopup()" class="btn btn-default"><i class="material-iconsadd text-default"></i> 어태치먼트추가</button>
								</div>
							</div>
							<div id="auiGrid" style="margin-top: 5px; height: 255px;"></div>
<!-- /어태치먼트 구성 -->
						</div>
						<div class="col-5">
							<div class="title-wrap mt10">
								<div class="left">
									<h4>이동이력</h4>
								</div>
							</div>
							<div id="auiGridTrans" style="margin-top: 5px; height: 255px;"></div>
						</div>
					</div>
				</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">					
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