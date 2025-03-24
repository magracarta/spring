<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 이동/재렌탈 > 센터 간 재렌탈 > null > 재렌탈신청상세
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
			createAUIGrid();
			fnInit();
			fnSetEdDt();
		});
		
		function goAcntProc(rentalCenterAcntNo) {
			var param = {
				rental_center_acnt_no : rentalCenterAcntNo
			}
			$M.goNextPageAjaxMsg("정산처리하시겠습니까?", this_page+"/acnt", $M.toGetParam(param), {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			location.reload();
						}
					}
				);
		}
		
		function fnInit() {
			centerAddr = new Object();
			var firstCd = "";
			<c:forEach items="${center}" var="item" varStatus="status">
			if ("${item.org_code}" != "") {
				<c:if test="${item.org_code eq SecureUser.org_code}">firstCd = "${item.org_code}"</c:if>
				centerAddr["${item.org_code}"] = ["${item.post_no}", "${item.addr1}"];
			}
			</c:forEach>
			//fnChangeDeliveryCd();
			if ("${rent.status_cd}" != "01") {
				$("#btnAddr").prop("disabled", true);
				$("#btnAttach").prop("disabled", true);
				$(".only01").prop("disabled", true);
			}
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
				//fnChangeOutOrgCode();
			}
		}
		
		function fnSetEdDt() {
			var mon = $M.getValue("mon_cnt");
			var stDt = $M.getValue("rental_st_dt");
			
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
			if ("${rent.status_cd}" != "05") {
				getMachinePrice();	
			}
		}
		
		function getMachinePrice() {
			if ($M.getValue("day_cnt") == "") {
	    		return false;
	    	}
			var mon = parseInt($M.getValue("mon_cnt"));
			var machineRentalPrice = 0;
			var totalRentalAmt = 0;
			var rentalAmt = 0;
			
			if ("${centerPrice.mon1_rental_price}" == "0") {
				alert("렌탈 > 렌탈비용 > 렌탈비관리-장비에서 결정 렌탈비를 등록해주세요.");
				return false;
			}

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
			<%--	//rentalAmt = machineRentalPrice *0.6;--%>
			<%--	rentalAmt = machineRentalPrice * 12;--%>
			<%--}--%>
			<%--console.log(machineRentalPrice);--%>
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
	   
	   function fnCalc() {
		   
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
					editable : false
				},
				{
					headerText : "수량",
					dataField : "qty",
					dataType : "numeric",
					style : "aui-center",
					formatString : "#,##0",
					width : "8%",
				},
				{
					headerText : "모델명",
					dataField : "part_no",
					style : "aui-center",
					width : "10%",
					editable : false
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
					style : "aui-center",
					formatString : "#,##0",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value != "" ? $M.setComma($M.getValue("day_cnt")) : "0"; // 어태치렌탈일수 = 장비렌탈일수
					}, 
					width : "10%",
					editable : false
				},
				{
					headerText : "렌탈금액",
					dataField : "amt",  
					dataType : "numeric",
					style : "aui-center",
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
							if ("${rent.status_cd}" != "01") {
								alert("작성중인 자료가 아닙니다.");
							} else {
								var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);
									fnCalc();
								} else {
									AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
									getAttachPrice();
								}
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				},
				{
					dataField : "rental_attach_no",
					visible : false
				},
				{
					dataField : "cmd",
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
			if ("${rent.status_cd}" != "01") {
				alert("작성중인 자료가 아닙니다.");
				return false;
			}
			
			// 2020-08-10 회의
			// 이동, 재렌탈는 소유센터의  어태치만 조회
			// 고객렌탈일떄는 관리센터의 어태치만 조회
			var rows = AUIGrid.getGridData(auiGrid);
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
		
		// 상신취소
		function goApprCancel() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				appr_cancel_yn : "Y"
			};
			openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
		}
		
		function goApprovalResultCancel(result) {
			$M.goNextPageAjax('/session/check', '', {method : 'GET'},
					function(result) {
				    	if(result.success) {
				    		alert("결재취소가 완료됐습니다.");	
				    		location.reload();
						}
					}
				);
		}
		
		// 결재처리
		function goApproval() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}"
			};
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}
		
		// 결재처리 결과
		function goApprovalResult(result) {
			console.log(result);
			// 반려이면 페이지 리로딩
			if(result.appr_status_cd == '03') {
				alert("반려가 완료됐습니다.");
				location.reload();
			} else {
				var form = $M.createForm();
				$M.setHiddenValue(form, 'appr_job_seq', $M.getValue("appr_job_seq"));
				var rentalCenterNo = $M.getValue("rental_center_no");
				$M.goNextPageAjax(this_page+"/"+rentalCenterNo+"/approval", form, {method : 'POST'},
					function(result) {
				    	if(result.success) {
				    		alert("처리가 완료됐습니다.");	
				    		location.reload();
						}
					}
				);
			}
		}
		
		//결재요청버튼
		function goRequestApproval() {
			goSave('appr');
		}
		
		// 수정버튼
		function goModify() {
			goSave();
		}
		
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
			var msg = appr == "appr" ? "결재요청하시겠습니까?" : "수정하시겠습니까?";
			
			var frm = $M.toValueForm(frm);
			var gridForm = fnChangeGridDataToForm(auiGrid);
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);
			appr = appr == undefined ? "modify" : appr;
			$M.setValue("save_mode", appr);
			$M.setValue("to_org_code", $M.getValue("to_org_code"));
			$M.goNextPageAjaxMsg(msg, this_page+"/"+$M.getValue("rental_center_no")+"/modify", gridForm, {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			alert("처리가 완료되었습니다.");
			    			location.reload();
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
		
		//닫기버튼
		function fnClose() {
			window.close();
		}
		
		//삭제버튼
		function goRemove() {
			$M.goNextPageAjaxRemove(this_page+"/"+$M.getValue("rental_center_no")+"/remove", '', {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			alert("처리가 완료되었습니다.");
			    			if (opener != null && opener.goSearch) {
			    				opener.goSearch();
			    			}
			    			fnClose();
						}
					}
				);
		}
		
		// 업무DB 연결 함수 21-08-06이강원
     	function openWorkDB(){
     		openWorkDBPanel('', ${rent.machine_plant_seq});
     	}
	
	</script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form">
<input type="hidden" id="rental_center_no" name="rental_center_no" value="${rent.rental_center_no }">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${rent.appr_job_seq}">
<input type="hidden" id="day_cnt" name="day_cnt" value="${rent.day_cnt}">
<input type="hidden" id="save_mode" name="save_mode">
<!-- 팝업 -->
    <div class="popup-wrap width-100per" style="min-width: 1250px">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<div class="left approval-left">
					<h4 class="primary">재렌탈신청 상세</h4>	
					<span class="condition-item">상태 : 
					<c:choose>
						<c:when test="${'01' eq rent.status_cd }">작성중</c:when>
						<c:when test="${'03' eq rent.status_cd }">결재중</c:when> 
						<c:when test="${'05' eq rent.status_cd and inputParam.s_current_dt < rent.rental_st_dt and rent.return_yn eq 'N'}">결재완료</c:when>
						<c:when test="${'05' eq rent.status_cd and inputParam.s_current_dt >= rent.rental_st_dt and rent.return_yn eq 'N'}">렌탈중</c:when>
						<c:otherwise>회수완료</c:otherwise>						
					</c:choose>
					</span>				
				</div>
<!-- 결재영역 -->
				<div class="pl10">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->
			</div>	
<!-- 폼테이블 1 -->				
			<table class="table-border mt10">
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
								<input type="text" class="form-control border-right-0 rb calDate only01" id="req_dt" name="req_dt" value="${rent.req_dt}" dateFormat="yyyy-MM-dd" alt="요청일" required="required">
							</div>
						</td>	
						<th class="text-right rs">요청센터</th>
						<td>
							<select class="form-control rb width120px only01" id="to_org_code" name="to_org_code" alt="요청센터" onchange="fnChangeOutOrgCode()">
								<c:forEach var="item" items="${orgCenterList}">
									<option value="${item.org_code}" <c:if test="${item.org_code eq rent.to_org_code }">selected</c:if>>${item.org_name}</option>
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
							<input type="text" class="form-control width120px" readonly="readonly" value="${rent.receipt_mem_name}">				
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
							<input type="text" class="form-control width120px" readonly>				
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
							<input type="hidden" id="from_org_code" name="from_org_code" value="${rent.from_org_code}">
							<input type="text" class="form-control width120px" readonly="readonly" value="${rent.from_org_name}">
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
					<!-- <div>
						<span>1년 : 40% / 60%</span>
						<span>6개월 : 60% / 40%</span>
						<span>3개월 : 80% / 20%</span>
					</div> -->
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
									<select id="mon_cnt" name="mon_cnt" class="form-control width80px only01" onchange="javascript:fnSetEdDt()">
										<option value="1" <c:if test="${rent.mon_cnt eq 1}">selected</c:if>>1개월</option>
										<option value="2" <c:if test="${rent.mon_cnt eq 2}">selected</c:if>>2개월</option>
										<option value="3" <c:if test="${rent.mon_cnt eq 3}">selected</c:if>>3개월</option>
										<option value="4" <c:if test="${rent.mon_cnt eq 4}">selected</c:if>>4개월</option>
										<option value="5" <c:if test="${rent.mon_cnt eq 5}">selected</c:if>>5개월</option>
										<option value="6" <c:if test="${rent.mon_cnt eq 6}">selected</c:if>>6개월</option>
										<option value="7" <c:if test="${rent.mon_cnt eq 7}">selected</c:if>>7개월</option>
										<option value="8" <c:if test="${rent.mon_cnt eq 8}">selected</c:if>>8개월</option>
										<option value="9" <c:if test="${rent.mon_cnt eq 9}">selected</c:if>>9개월</option>
										<option value="10" <c:if test="${rent.mon_cnt eq 10}">selected</c:if>>10개월</option>
										<option value="11" <c:if test="${rent.mon_cnt eq 11}">selected</c:if>>11개월</option>
										<option value="12" <c:if test="${rent.mon_cnt eq 12}">selected</c:if>>12개월</option>
									</select>
								</div>
								<div class="col width105px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate rb only01" id="rental_st_dt" name="rental_st_dt" dateFormat="yyyy-MM-dd"  alt="렌탈 시작일" value="${rent.rental_st_dt}" onchange="javascript:fnSetEdDt()">
									</div>
								</div>
								<div class="col width16px text-center">~</div>
								<div class="col width120px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="rental_ed_dt" name="rental_ed_dt" dateFormat="yyyy-MM-dd" alt="렌탈 종료일" disabled="disabled" value="${rent.rental_ed_dt}">
									</div>
								</div>
							</div>
						</td>
						<th class="text-right">신청재렌탈료</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" format="decimal" id="rental_amt" name="rental_amt" alt="신청재렌탈료" value="${rent.rental_amt}">
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
									<input type="text" class="form-control text-right" readonly value="${rent.total_rental_amt}" id="total_rental_amt" name="total_rental_amt" format="decimal">
								</div>
								<div class="col width16px">원</div>
								(고객 총렌탈료)
							</div>
						</td>
						<th class="text-right">최소렌탈료</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly id="min_rental_price" name="min_rental_price" value="${rent.min_rental_price }" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">재렌탈기준가</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${rent.base_rental_price}" format="decimal" id="base_rental_price" name="base_rental_price">
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
								<select class="form-control rb only01" id="rental_delivery_cd" name="rental_delivery_cd" alt="인도방법" required="required" onchange="fnChangeDeliveryCd()">
									<option value="">- 선택 -</option>
									<c:forEach var="item" items="${codeMap['RENTAL_DELIVERY']}">
										<option value="${item.code_value}" <c:if test="${item.code_value eq rent.rental_delivery_cd }">selected</c:if>>${item.code_name}</option>
									</c:forEach>
								</select>
							</div>
						</td>
						<th class="text-right">운송구분(신청자기준)</th>
						<td>
							<div class="form-check form-check-inline dc">
								<input class="form-check-input only01" type="radio" checked="checked" value="P" name="delivery_pay_type_pl" id="delivery_pay_type_pl_p" <c:if test="${'P' eq rent.delivery_pay_type_pl }">checked</c:if>>
								<label class="form-check-label" for="delivery_pay_type_pl_p">선불</label>
							</div>
							<div class="form-check form-check-inline dc">
								<input class="form-check-input only01" type="radio" value="L" name="delivery_pay_type_pl" id="delivery_pay_type_pl_l" <c:if test="${'L' eq rent.delivery_pay_type_pl }">checked</c:if>>
								<label class="form-check-label" for="delivery_pay_type_pl_l">착불</label>
							</div>
						</td>
						<th class="text-right">운송료</th>
						<td>
							<div class="form-row inline-pd widthfix dc only01">
								<div class="col width100px">
									<input type="text" class="form-control text-right only01" format="decimal" id="delivery_amt" name="delivery_amt" alt="운송료" format="decimal" value="${rent.delivery_amt}">
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
                                           id="delivery_post_no" name="delivery_post_no" value="${rent.delivery_post_no }"
                                           alt="우편번호">
                                </div>
                                <div class="col-auto pdl5">
                                    <button type="button" class="btn btn-primary-gra full dc" id="btnAddr"
                                            onclick="javascript:openSearchAddrPanel('fnSetAddr');">주소찾기
                                    </button>
                                </div>
                                <div class="col-5">
                                    <input type="text" class="form-control" readonly="readonly"
                                           id="delivery_addr1" name="delivery_addr1" value="${rent.delivery_addr1}"
                                           alt="주소">
                                </div>
                                <div class="col-4">
                                    <input type="text" class="form-control only01" value="${rent.delivery_addr2}"
                                           id="delivery_addr2" name="delivery_addr2" alt="상세 주소" maxlength="75">
                                </div>
                            </div>									
						</td>
					</tr>
					<tr>
						<th class="text-right">비고</th>
						<td colspan="5">
							<textarea class="form-control only01" style="height: 70px;" id="remark" name="remark" maxlength="100">${rent.remark }</textarea>						
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
				<div class="col-5">
<!-- 결재자의견 -->	
				<c:if test="${apprMemoList != null && apprMemoList.size() != 0}">
					<div id="apprMemoList">
						<div class="title-wrap mt10">
							<h4>결재자의견</h4>									
						</div>
						<table class="table-border doc-table md-table" style="margin-top: 5px">
							<colgroup>
								<col width="40px">
								<col width="140px">
								<col width="55px">
								<col width="">
							</colgroup>
							<thead>
								<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
								<tr><th class="th" style="font-size: 12px !important">구분</th>
								<th class="th" style="font-size: 12px !important">결재일시</th>
								<th class="th" style="font-size: 12px !important">담당자</th>
								<th class="th" style="font-size: 12px !important">특이사항</th>
							</tr></thead>
							<tbody>
								<c:forEach var="list" items="${apprMemoList}">
									<tr>
										<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
										<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
										<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
										<td class="td" style="font-size: 12px !important">${list.memo }</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
					</div>
				</c:if>
<!-- /결재자의견 -->		
				<c:if test="${not empty acntList}">
					<div class="title-wrap mt5">
							<h4>매출처리 - 마지막 정산 시, 신청 당시 관리센터(${rent.from_org_name })로 장비 및 어태치먼트의 관리센터가 변경됩니다.</h4>									
						</div>
						<table class="table-border doc-table md-table" style="margin-top: 5px">
							<colgroup>
								<col width="">
								<col width="">
								<col width="">
							</colgroup>
							<thead>
								<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
								<tr>
									<th class="th" style="font-size: 12px !important">개월</th>
									<th class="th" style="font-size: 12px !important">기간</th>
									<th class="th" style="font-size: 12px !important">정산처리</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="list" items="${acntList}">
									<tr>
										<td class="td" style="text-align: center; font-size: 12px !important">${list.rownum} 개월차</td>
										<td class="td" style="font-size: 12px !important">
											${list.acnt_st_dt} ~ ${list.acnt_ed_dt}
											<c:if test="${list.proc_flag_yn eq 'N'}">
												<c:set var="tempDate" value="${list.acnt_available_dt}"/>
					                            <strong style="color:red; float: right;">
					                            	<c:out value="${fn:substring(tempDate,0,4) }"/>-<c:out value="${fn:substring(tempDate,4,6) }"/>-<c:out value="${fn:substring(tempDate,6,8) }"/>일 이후 정산처리 버튼 오픈예정</strong>
											</c:if>
										</td>
										<td class="td" style="text-align: center; font-size: 12px !important">
											<c:if test="${list.proc_flag_yn eq 'Y'}">
												<button type="button" ${list.acnt_proc_yn eq 'Y' ? 'disabled="disabled"' : '' } onclick="javascript:goAcntProc('${list.rental_center_acnt_no}')" class="btn btn-default acnt">정산처리</button>
											</c:if>
										</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
				</c:if>
				</div>
			</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
						<jsp:param name="mem_no" value="${rent.receipt_mem_no}"/>
						<jsp:param name="appr_yn" value="Y"/>
					</jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>