<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 이동/재렌탈 > 센터 간 재렌탈 > 재렌탈신청 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		var auiGrid;
		var centerAddr;
		
		$(document).ready(function () {
			console.log("${centerPrice}");
			createAUIGrid();
			fnInit();
			fnSetEdDt();
		});
		
		function fnInit() {
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
		
		function fnChangeOutOrgCode() {
			var cd = $M.getValue("to_org_code");
			if (cd != "") {
				$M.setValue("delivery_post_no", centerAddr[cd][0]);
				$M.setValue("delivery_addr1", centerAddr[cd][1]);
			} 
		}
		
		function fnChangeDeliveryCd() {
			var cd = $M.getValue("rental_delivery_cd");
			if (cd == "01") {
				$(".dc *").attr("disabled", true);  
			} else {
				$(".dc *").attr("disabled", false);
				// fnChangeOutOrgCode();
			}
		}
		
		function fnSetEdDt() {
			var stDt = $M.getValue("rental_st_dt");
			var mon = $M.getValue("mon_cnt");
			// ASIS 로직(+1달한 후 -1일 뺌)
			// var ed = $M.addMonths($M.toDate(stDt), $M.toNum(mon));
			// ed = $M.addDates(ed, -1);
			
			// TOBE 로직(2020-08-10 회의 김태공 상무님 지시사항으로 무조건 한달은 30일로계산, 12개월은 360일로함.)
			var ed = $M.addDates($M.toDate(stDt), 30*mon);
			ed = $M.addDates(ed, -1);
			
			var param = {
				rental_ed_dt : ed,
				day_cnt : $M.getDiff(ed, stDt)
			};
			
			$M.setValue(param);
			AUIGrid.resize(auiGrid);
			
			getMachinePrice();
		}
		
		function getMachinePrice() {
			if ($M.getValue("day_cnt") == "") {
	    		return false;
	    	}
			var mon = parseInt($M.getValue("mon_cnt"));
			var machineRentalPrice = 0;
			var totalRentalAmt = 0;
			var rentalAmt = 0;

			// Q&A 23459. 렌탈기간 단위 변경 요청(기존 3,6,12개월 -> 1~12개월)
			var monthPrices = [
				"${centerPrice.mon1_price}",
				"${centerPrice.mon2_price}",
				"${centerPrice.mon3_price}",
				"${centerPrice.mon4_price}",
				"${centerPrice.mon5_price}",
				"${centerPrice.mon6_price}",
				"${centerPrice.mon7_price}",
				"${centerPrice.mon8_price}",
				"${centerPrice.mon9_price}",
				"${centerPrice.mon10_price}",
				"${centerPrice.mon11_price}",
				"${centerPrice.mon12_price}"
			];

			if ("${centerPrice.mon1_rental_price}" == "0") {
				alert("렌탈 > 렌탈비용 > 렌탈비관리-장비에서 결정 렌탈비를 등록해주세요.");
				return false;
			}

			machineRentalPrice = monthPrices[mon-1];
			totalRentalAmt = $M.toNum("${centerPrice.mon1_rental_price}") * mon
			rentalAmt = machineRentalPrice * mon

			<%--// 아래 계산은 확인이필요함.--%>
			<%--if (mon == "3") {--%>
			<%--	machineRentalPrice = "${centerPrice.mon3_price}";--%>
			<%--	totalRentalAmt = $M.toNum("${centerPrice.mon1_rental_price}")*3;--%>
			<%--	// 재렌탈가격이 등록안되있으면, 한달렌탈금액-월감가 * 월수로 계산--%>
			<%--	/* if (machineRentalPrice == "0") {--%>
			<%--		machineRentalPrice = ($M.toNum("${centerPrice.mon1_rental_price}") - $M.toNum("${centerPrice.mon1_reduce_price}"))*3;--%>
			<%--	} */--%>
			<%--	// rentalAmt = machineRentalPrice *0.2;--%>
			<%--	rentalAmt = machineRentalPrice * 3;--%>
			<%--} else if (mon == "6") {--%>
			<%--	machineRentalPrice = "${centerPrice.mon6_price}";--%>
			<%--	totalRentalAmt = $M.toNum("${centerPrice.mon1_rental_price}")*6;--%>
			<%--	/* if (machineRentalPrice == "0") {--%>
			<%--		machineRentalPrice = ($M.toNum("${centerPrice.mon1_rental_price}") - $M.toNum("${centerPrice.mon1_reduce_price}"))*6;--%>
			<%--	} */--%>
			<%--	//rentalAmt = machineRentalPrice *0.4;--%>
			<%--	rentalAmt = machineRentalPrice * 6;--%>
			<%--} else if (mon == "12") {--%>
			<%--	machineRentalPrice = "${centerPrice.mon12_price}";--%>
			<%--	totalRentalAmt = $M.toNum("${centerPrice.mon1_rental_price}")*12;--%>
			<%--	/* if (machineRentalPrice == "0") {--%>
			<%--		machineRentalPrice = ($M.toNum("${centerPrice.mon1_rental_price}") - $M.toNum("${centerPrice.mon1_reduce_price}"))*12;--%>
			<%--	} */--%>
			<%--	// rentalAmt = machineRentalPrice *0.6;--%>
			<%--	rentalAmt = machineRentalPrice * 12;--%>
			<%--}--%>
			var param = {
				total_rental_amt : totalRentalAmt,
				base_rental_price : machineRentalPrice,
				rental_amt : rentalAmt
			}
			$M.setValue(param);
			getAttachPrice();
		}
		
	   function getAttachPrice() {
	    	var rows = AUIGrid.getGridData(auiGrid);
	    	var dayCnt = $M.toNum($M.getValue("day_cnt"));
	    	if (rows.length < 1 || dayCnt == 0) {
	    		fnCalc();
	    		return false;
	    	}
	    	var dayArr = [];
	    	for (var i = 0; i < rows.length; ++i) {
	    		dayArr.push(dayCnt);
	    		AUIGrid.updateRow(auiGrid, {"day_cnt" : dayCnt },i);
	    	}
	    	var param = {
	    		rental_attach_no_str : $M.getArrStr(rows, {sep : "#", key : "rental_attach_no", isEmpty : true}),
	    		day_cnt_str : $M.getArrStr(dayArr),
	    		base_yn_str : $M.getArrStr(rows, {sep : "#", key : "base_yn", isEmpty : true}),
	    		cost_yn_str : $M.getArrStr(rows, {sep : "#", key : "cost_yn", isEmpty : true}),
	    	}
			$M.goNextPageAjax("/rent/rent010101/calc/attach", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			console.log(result);
			    			var total = 0;
			    			for (var i = 0; i < result.attachPrice.length; ++i) {
			    				total+=result.attachPrice[i];
			    				var obj = {
			    					amt :  result.attachPrice[i]
			    				}
			    				AUIGrid.updateRow(auiGrid, obj, i);
			    			}
			    			fnCalc();
						}
					}
				);
	    }
		
		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				rowIdField : "_$uid",
				showRowNumColum : true
			};
	
			var columnLayout = [
				{
					headerText : "어태치먼트명",
					dataField : "attach_name",
					style : "aui-left",
					width : "24%",
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					style : "aui-center",
					width : "10%",
					editable : false
				},
				{
					headerText : "수량",
					dataField : "qty",
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0",
					width : "8%",
				},
				{
					headerText : "매입처",
					dataField : "client_name",
					style : "aui-center",
					width : "15%",
					editable : false
				},
				{
					headerText : "일련번호",
					dataField : "product_no",
					style : "aui-center",
					width : "13%",
					editable : false
				},
				{
					headerText : "렌탈일수",
					dataField : "day_cnt",
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0",
					width : "10%",
					editable : false
				},
				{
					headerText : "렌탈금액",
					dataField : "amt",  
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0",
					width : "10%",
					editable : false
				},
				{
					headerText : "삭제",
					dataField : "h",
					width : "10%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.removeSoftRows(auiGrid);
							fnCalc();
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					}
				},
				{
					dataField : "rental_attach_no",
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
			AUIGrid.resize(auiGrid);
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
		    openRentalAttachPanel("fnSetAttach", $M.toGetParam(params));
	    }
		
		function fnSetAttach(row) {
			var item = new Object();
			if(row != null) {
				for(i=0; i<row.length; i++) {
					item.part_name = row[i].part_name;
					item.attach_name = row[i].attach_name;
					item.part_no = row[i].part_no;
					item.qty = 1;
					item.product_no = row[i].product_no;
					item.client_name = row[i].client_name;
					item.rental_attach_no = row[i].rental_attach_no;
					item.day_cnt = $M.getValue("day_cnt");
					item.amt = 0;
					item.cost_yn = row[i].cost_yn;
					item.base_yn = row[i].base_yn;
					AUIGrid.addRow(auiGrid, item, 'last');
				}
				getAttachPrice();
			}
			AUIGrid.resize(auiGrid);
		}
		
		function getAttachPrice() {
	    	var rows = AUIGrid.getGridData(auiGrid);
	    	var dayCnt = $M.toNum($M.getValue("day_cnt"));
	    	if (rows.length < 1 || dayCnt == 0) {
	    		fnCalc();
	    		return false;
	    	}
	    	var dayArr = [];
	    	for (var i = 0; i < rows.length; ++i) {
	    		dayArr.push(dayCnt);
	    		AUIGrid.updateRow(auiGrid, {"day_cnt" : dayCnt },i);
	    	}
	    	var param = {
	    		rental_attach_no_str : $M.getArrStr(rows, {sep : "#", key : "rental_attach_no", isEmpty : true}),
	    		day_cnt_str : $M.getArrStr(dayArr),
	    		base_yn_str : $M.getArrStr(rows, {sep : "#", key : "base_yn", isEmpty : true}),
	    		cost_yn_str : $M.getArrStr(rows, {sep : "#", key : "cost_yn", isEmpty : true}),
	    	}
			$M.goNextPageAjax("/rent/rent010101/calc/attach", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			console.log(result);
			    			var total = 0;
			    			for (var i = 0; i < result.attachPrice.length; ++i) {
			    				total+=result.attachPrice[i];
			    				var obj = {
			    					amt :  result.attachPrice[i]
			    				}
			    				AUIGrid.updateRow(auiGrid, obj, i);
			    			}
			    			fnCalc();
						}
					}
				);
	    }
		
		function fnCalc() {
			
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
				if ($M.validation(frm, {field : ['delivery_post_no']}) == false) {
					return false;					
				}
			}
			if ($M.getValue("to_org_code") == $M.getValue("from_org_code")) {
				alert("요청센터를 다시 확인해주세요.");
				$("#to_org_code").focus();
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
			// console.log(appr);
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
			history.back();
		}
		
		// 업무DB 연결 함수 21-08-05이강원
     	function openWorkDB(){
     		openWorkDBPanel('',${rent.machine_plant_seq});
     	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="from_org_code" name="from_org_code" value="${rent.mng_org_code}">
<input type="hidden" id="day_cnt" name="day_cnt">
<input type="hidden" id="save_mode" name="save_mode">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
<!-- 상세페이지 타이틀 -->
			<div class="main-title detail">
				<div class="detail-left approval-left" style="align-items: center;">
					<div class="left">
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
							<col width="">
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
										<input type="text" class="form-control border-right-0 rb calDate" id="req_dt" name="req_dt" value="${inputParam.s_current_dt}" dateFormat="yyyy-MM-dd" alt="요청일" required="required">
									</div>
								</td>	
								<th class="text-right rs">요청센터</th>
								<td>
									<select class="form-control rb width120px" id="to_org_code" name="to_org_code" alt="요청센터" onchange="fnChangeOutOrgCode()" ${page.fnc.F00992_001 eq 'Y' ? 'disabled' : ''}>
										<c:forEach var="item" items="${orgCenterList}">
												<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code }">selected</c:if>>${item.org_name}</option>
										</c:forEach>
									</select>
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
											<input type="text" class="form-control width120px" readonly="readonly" value="${rent.machine_name}">	
										</div>
										<div class="col-auto">
											<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
										</div>
									</div>		
								</td>	
								<th class="text-right">요청자</th>
								<td>
									<input type="text" class="form-control width120px" readonly="readonly" value="${SecureUser.kor_name}">				
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
								<th class="text-right">출하일자</th>
								<td>
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
								<th class="text-right">관리센터</th>
								<td>
									<input type="text" class="form-control width120px" readonly="readonly" value="${rent.mng_org_name}">
								</td>
							</tr>
						</tbody>
					</table>
<!-- 폼테이블 1 -->	
<!-- 재렌탈 신청정보 -->				
					<div class="title-wrap mt10">
						<div class="left">
							<h4>재렌탈 신청정보</h4>
						</div>
						<div class="right">
							<button type="button" onclick="goEquipment();" class="btn btn-default">렌탈장비대장</button>
							<button type="button" onclick="goRepairHistory();" class="btn btn-default">수리이력</button>
						</div>
					</div>	
					<table class="table-border mt5">
						<colgroup>
							<col width="120px">
							<col width="">
							<col width="120px">
							<col width="">
							<col width="120px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right rs">렌탈기간</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px" style="min-width: 100px">
											<select id="mon_cnt" name="mon_cnt" class="form-control width80px" onchange="javascript:fnSetEdDt()">
												<option value="1" selected="selected">1개월</option>
												<option value="2">2개월</option>
												<option value="3">3개월</option>
												<option value="4">4개월</option>
												<option value="5">5개월</option>
												<option value="6">6개월</option>
												<option value="7">7개월</option>
												<option value="8">8개월</option>
												<option value="9">9개월</option>
												<option value="10">10개월</option>
												<option value="11">11개월</option>
												<option value="12">12개월</option>
											</select>
<%--											<div class="form-check form-check-inline">--%>
<%--												<input class="form-check-input" type="radio" name="mon_cnt" id="mon3" checked="checked" onchange="javascript:fnSetEdDt()" value="3">--%>
<%--												<label class="form-check-label" for="mon3">3개월</label>--%>
<%--											</div>--%>
<%--											<div class="form-check form-check-inline">--%>
<%--												<input class="form-check-input" type="radio" name="mon_cnt" id="mon6" onchange="javascript:fnSetEdDt()" value="6">--%>
<%--												<label class="form-check-label" for="mon6">6개월</label>--%>
<%--											</div>--%>
<%--											<div class="form-check form-check-inline">--%>
<%--												<input class="form-check-input" type="radio" name="mon_cnt" id="mon12" onchange="javascript:fnSetEdDt()" value="12">--%>
<%--												<label class="form-check-label" for="mon12">12개월</label>--%>
<%--											</div>--%>
										</div>
										<div class="col width105px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate rb" id="rental_st_dt" name="rental_st_dt" dateFormat="yyyy-MM-dd"  alt="렌탈 시작일" value="${inputParam.s_current_dt}" onchange="javascript:fnSetEdDt()">
											</div>
										</div>
										<div class="col width16px text-center">~</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="rental_ed_dt" name="rental_ed_dt" dateFormat="yyyy-MM-dd" alt="렌탈 종료일" disabled="disabled">
											</div>
										</div>
									</div>
								</td>
								<th class="text-right">신청재렌탈료</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" format="decimal" id="rental_amt" name="rental_amt" alt="신청재렌탈료">
										</div>
										<div class="col width16px">원</div>
										(재렌탈 등록 기준가 x 기간)
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">총렌탈료</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" format="decimal" id="total_rental_amt" name="total_rental_amt">
										</div>
										<div class="col width16px">원</div>
										(고객 총렌탈료)
									</div>
								</td>
								<th class="text-right">최소렌탈료</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" format="decimal" id="min_rental_price" name="min_rental_price">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">재렌탈기준가</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" value="${centerPrice.base_rental_price}" format="decimal" id="base_rental_price" name="base_rental_price">
										</div>
										<div class="col width16px">원</div>
										(재렌탈 등록 기준가)
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right rs">인도방법</th>
								<td>
									<div class="width100px">
										<select class="form-control rb" id="rental_delivery_cd" name="rental_delivery_cd" alt="인도방법" required="required" onchange="fnChangeDeliveryCd()">
											<option value="">- 선택 -</option>
											<c:forEach var="item" items="${codeMap['RENTAL_DELIVERY']}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
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
									<textarea class="form-control" style="height: 70px;" id="remark" name="remark" maxlength="100"></textarea>						
								</td>
							</tr>							
						</tbody>
					</table>
<!-- /재렌탈 신청정보 -->
					<div class="row">
						<div class="col-7">
<!-- 어태치먼트 구성 -->
							<div class="title-wrap mt10">
								<div class="left">
									<h4>어태치먼트 구성</h4>
								</div>
								<div class="right">
									<button type="button" onclick="goAttachPopup();" class="btn btn-default"><i class="material-iconsadd text-default"></i> 어태치먼트추가</button>
								</div>
							</div>
							<div id="auiGrid" style="margin-top: 5px; height: 255px;"></div>
<!-- /어태치먼트 구성 -->
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