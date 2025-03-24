<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > null > 렌탈장비대장상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		// GPS 수정됐는지 감지
		var gpsNo = "${item.gps_no}";

		// 감가수정했는지 감지(이 정보가 저장할때 바뀌면 감가이력에 등록)
		var initReduceYn = "${item.reduce_yn}";
		var initRduceStDt = "${item.reduce_st_dt}";
		var initRduceEdDt = "${item.reduce_ed_dt}";

		$(document).ready(function() {
			fnSetInit();

			// 2021-06-30 (Q&A : 10591) 판매완료건은 판매정보 버튼으로 보여지도록 수정요청
			if ("${item.rental_pos_status_cd}" == "9") {
				$("#_goRentalSalePopup").hide();
			} else {
				$("#_goRentalSaleInfoPopup").hide();
			}

			if("${item.rental_pos_status_cd}" == "9" && "${item.inout_doc_no}" != "") {
				$("#_goSale").hide();
				$("#_goSaleDetail").show();
			} else if("${item.rental_pos_status_cd}" == "9" && "${item.inout_doc_no}" == "") {
				$("#_goSale").show();
				$("#_goSaleDetail").hide();
			} else {
				$("#_goSale").hide();
				$("#_goSaleDetail").hide();
			}

			// 장비매각관련
			if ("${item.mch_sale_yn}" == "Y") {
				$("#mch_sale_label").toggleClass("dpn");

				var mchSaleDate = "${item.mch_sale_date}";
				var mchSaleMemName = "${item.mch_sale_mem_name}";

				$("#mch_sale_area").text(mchSaleDate + ' ' + mchSaleMemName);
			}
		});

		function fnSetInit() {
			//fnCalcReduceMonth();
			fnSetReduceYn();
		}

		// 매출상세
		function goSaleDetail() {
			var params = {
						"inout_doc_no" : $M.getValue("inout_doc_no")
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
			$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 매출
		function goSale() {
			var param = {
					"rental_machine_no" : $M.getValue("rental_machine_no")
			};
    		openInoutProcPanel("fnSetInout", $M.toGetParam(param));
		}

		// 렌탈이력
	    function goRentalHisPopup() {
	    	var params = {
	    		machine_name : "${item.machine_name}",
	    		body_no : "${item.body_no}",
	     		rental_machine_no : "${item.rental_machine_no}"
	     	};
	    	var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p04', $M.toGetParam(params), {popupStatus : popupOption});
	    }

		//이동이력
	    function goMoveHisPopup() {
	     	var params = {
	     		rental_machine_no : "${item.rental_machine_no}"
	     	};
	     	var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p05', $M.toGetParam(params), {popupStatus : popupOption});

	    }

	  	//수리이력
	    function goAsHisPop() {
	    	var params = {
		     		s_machine_seq : "${item.machine_seq}"
		    };
		   	var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
	    }

	  	//판매이력
	    function goSaleHisPop() {
	    	var params = {
	     		rental_machine_no : "${item.rental_machine_no}"
	     	};
	    	var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p06', $M.toGetParam(params), {popupStatus : popupOption});
	    }

		//감가이력
	    function goReduceHisPop() {
	    	var params = {
	     		rental_machine_no : "${item.rental_machine_no}"
	     	};
			var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p07', $M.toGetParam(params), {popupStatus : popupOption});
	    }

		//판매처리 팝업 호출
	    function goRentalSalePopup() {
	    	var params = {
					rental_machine_no : "${item.rental_machine_no}",
					attach_mng_org_code: $M.getValue('mng_org_code'),
				};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=450, height=550, left=0, top=0";
			$M.goNextPage('/rent/rent0201p02', $M.toGetParam(params), {popupStatus : popupOption});
	    }

		// 수정
	    function goModify() {
	    	var frm = document.main_form;
	    	if ($M.getValue("reduce_yn") == "Y") {
				if($M.validation(frm, {field:["reduce_st_dt"]}) == false) {
					return;
				}
				if($M.checkRangeByFieldName('reduce_st_dt', 'reduce_ed_dt', true) == false) {
					return;
				};
			} else {
				if($M.validation(frm) == false) {
					return;
				}
			}
	    	if (gpsNo != $M.getValue("gps_no")) {
	    		$M.setValue("gpsUpdateYn", "Y");
	    	}
	    	if (initReduceYn != $M.getValue("reduce_yn") ||
	    		initRduceStDt != $M.getValue("reduce_st_dt") ||
	    		initRduceEdDt != $M.getValue("reduce_ed_dt")) {
	    		$M.setValue("reduceUpdateYn", "Y");
	    	}
			$M.goNextPageAjaxModify(this_page, $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("수정처리 되었습니다");
						window.location.reload();
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
					}
				}
			);
	    }

		// 삭제
	    function goRemove() {
	    	var rental_machine_no = "${item.rental_machine_no}";
	    	$M.goNextPageAjaxRemove(this_page + '/remove/' + rental_machine_no, "", {method : 'POST'},
	   			function(result) {
	   				if(result.success) {
	   					alert("삭제처리 되었습니다");
						fnClose();
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
	   				}
	   			}
	   		);
	    }

		// 닫기
	    function fnClose() {
	    	window.close();
	    }

	    // gps대장
	    function goGps() {
	    	var param = {
	    		machine_seq : "${item.machine_seq}"
			};
	    	openGpsPanel('setGpsInfo', $M.toGetParam(param));
	    }

	    // gps 선택한 값 세팅
	    function setGpsInfo(data) {
	    	$M.setValue("gps_seq", data.gps_seq);
	    	$M.setValue("gps_type_cd", data.gps_type_cd);
	    	$M.setValue("gps_no", data.gps_no);
	    }

	    function fnSetReduceYn() {
	    	var reduceYn = $M.getValue("reduce_yn");
	    	if (reduceYn == "Y") {
	    		$("#reduce_st_dt").prop("readonly", false);
	    		$("#reduce_ed_dt").prop("readonly", false);
	    		$(".r1s").addClass("rs");
	    		$(".r1b").addClass("rb");
	    		if ($M.getValue("reduce_st_dt") == "") {
	    			fnSetReduceStDt();
	    		}
	    	} else {
	    		$("#reduce_st_dt").prop("readonly", true);
	    		$("#reduce_ed_dt").prop("readonly", true);
	    		$(".r1s").removeClass("rs");
	    		$(".r1b").removeClass("rb");
	    	}
	    	fnCalcReduceMonth();
	    }

	    function fnSetReduceStDt() {
	    	$M.setValue("reduce_st_dt", $M.getValue("buy_dt"));
	    }

	    function goMachineDoc(docNo) {
	    	var param = {
	    		machine_doc_no : docNo
	    	}
	    	var poppupOption = "";
	    	$M.goNextPage("/sale/sale0101p03", $M.toGetParam(param), {popupStatus : poppupOption});
	    }

	    function fnCalcReduceMonth() {
	    	if ($M.getValue("reduce_st_dt") == "") {
	    		$M.setValue("reduce_month", 0);
	    	} else {
	    		if ($M.getValue("reduce_ed_dt") == "") {
	    			// 감가종료일이 없으면 오늘날짜까지 감가 계산
	    			var cnt = $M.getDiff("${inputParam.s_current_dt}", $M.getValue("reduce_st_dt"));
	    			$M.setValue("reduce_month", Math.ceil((cnt/30)*10)/10);
	    		} else {
	    			if ($M.toNum($M.getValue("reduce_st_dt")) > $M.toNum($M.getValue("reduce_ed_dt"))) {
		    			$M.setValue("reduce_ed_dt", $M.getValue("reduce_st_dt"));
		        		alert("감가종료일이 감가 시작 이전 입니다.\n감가종료일을 다시 지정해주세요.");
		        		$M.setValue("reduce_month", 0);
		    		} else {
		    			var cnt = $M.getDiff($M.getValue("reduce_ed_dt"), $M.getValue("reduce_st_dt"));
		    			$M.setValue("reduce_month", Math.ceil((cnt/30)*10)/10);
		    		}
	    		}
	    	}
	    }

	 	// 업무DB 연결 함수 21-08-06 이강원
     	function openWorkDB(){
     		openWorkDBPanel('${item.machine_seq}','${item.machine_plant_seq}');
     	}

     	function fnSetInout() {
 		   location.reload();
 	   }

		// 장비대장
		function goMachineDetail() {
			var machineSeq = $M.getValue("machine_seq");

			// 보낼 데이터
			var params = {
				"s_machine_seq" : machineSeq
			};

			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
			$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function fnMchSaleProc() {
			alert("장비매각정보는 '매각요청' 버튼을 통해서만 수정 됩니다.");

			var check = $M.getValue("mch_sale_yn");
			if (check == 'Y') {
				$("#mch_sale_label").toggleClass("dpn");

				var now = $M.getCurrentDate("yyyy-MM-dd HH:mm");
				var memKorName = "${SecureUser.kor_name}";
				$("#mch_sale_area").text(now + ' ' + memKorName);
				$M.setValue("mch_sale_check_yn", "Y");
			} else {
				$("#mch_sale_label").removeClass("dpn");
				$("#mch_sale_area").text('');
				$M.setValue("mch_sale_check_yn", "N");
			}
		}

		// 장비매각요청
		function goMchSaleProc() {
			if (confirm("장비매각의 정보만 수정됩니다\n저장 하시겠습니까?") == false) {
				return false;
			}

			var param = {
				"rental_machine_no" : $M.getValue("rental_machine_no"),
				"mch_sale_check_yn" : $M.getValue("mch_sale_check_yn")
			}
			$M.goNextPageAjax(this_page + '/mch_sale/', $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("저장이 완료되었습니다.");
							window.location.reload();
							if (opener != null && opener.goSearch) {
								opener.goSearch();
							}
						}
					}
			);

		}

		function show() {
			document.getElementById("rental_operation").style.display="block";
		}
		function hide() {
			document.getElementById("rental_operation").style.display="none";
		}

	</script>
</head>
<body   class="bg-white"  >
<form id="main_form" name="main_form">
	<input type="hidden" name="mch_sale_check_yn">
	<input type="hidden" name="gpsUpdateYn" value="N">
	<input type="hidden" name="reduceUpdateYn" value="N">
	<input type="hidden" name="inout_doc_no" id="inout_doc_no" value="${item.inout_doc_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<h4>렌탈장비대장상세</h4>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
<!-- 폼 테이블 -->
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="130px">
					<col width="100px">
					<col width="130px">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="110px">
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">관리번호</th>
						<td colspan="3">
							<input type="hidden" id="rental_machine_no" name="rental_machine_no" value="${item.rental_machine_no}">
							<div class="form-row inline-pd widthfix">
								<div class="col width110px">
									<%-- <input type="text" class="form-control" readonly="readonly" value="${fn:substring(item.rental_machine_no, 0, 6)}"> --%>
									<input type="text" class="form-control" readonly="readonly" value="${item.rental_machine_no}">
								</div>
								<%-- <div class="col width16px text-center">-</div>
								<div class="col width50px">
									<input type="text" class="form-control" readonly="readonly" value="${fn:substring(item.rental_machine_no, 7, 11)}">
								</div> --%>
								<c:if test="${not empty item.machine_doc_no }">
									<div class="col width50px">
										<button type="button" class="btn btn-default" onclick="javascript:goMachineDoc('${item.machine_doc_no}')">출하의뢰서</button>
									</div>
								</c:if>
							</div>
						</td>
						<th class="text-right rs">매입일자</th>
						<td>
							<div class="input-group width100px">
								<input type="text" class="form-control rb border-right-0 calDate" required="required" id="buy_dt" name="buy_dt" dateFormat="yyyy-MM-dd" value="${item.buy_dt}" alt="매입일자">
							</div>
						</td>
						<th class="text-right">감가여부</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width140px">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" required="required" id="reduce_y" name="reduce_yn" ${item.reduce_yn eq 'Y' ? 'checked="checked"' : ''} value="Y" onclick="javascript:fnSetReduceYn()">
										<label class="form-check-label" for="reduce_y">적용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" required="required" id="reduce_n" name="reduce_yn" ${item.reduce_yn eq 'N' ? 'checked="checked"' : ''} value="N" onclick="javascript:fnSetReduceYn()">
										<label class="form-check-label" for="reduce_n">미적용</label>
									</div>
								</div>
								<div class="col width28px">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
								</div>
							</div>
						</td>
						<th class="text-right rs">소유센터</th>
						<td>
							<select class="form-control width90px rb" required="required" id="own_org_code" name="own_org_code" alt="소유센터">
								<option value="">- 선택 -</option>
								<c:forEach var="orgitem" items="${orgCenterList}">
									<option value="${orgitem.org_code}" ${orgitem.org_code eq item.own_org_code ? 'selected="selected"' : ''}>${orgitem.org_name}</option>
								</c:forEach>
								<option value="5010">서비스지원</option>
							</select>
						</td>
					</tr>
					<tr>
						<th class="text-right">메이커</th>
						<td colspan="3">
							<div class="input-group">
								<input type="text" class="form-control border-right-0" value="${item.maker_name}" disabled="disabled">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:go10();"  ><i class="material-iconssearch"></i></button>
							</div>
						</td>
						<th class="text-right">매입종류</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width130px">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" required="required" id="buy_type_un_n" name="buy_type_un" value="N" ${item.buy_type_un eq 'N' ? 'checked="checked"' : ''}>
										<label class="form-check-label" for="buy_type_un_n">신차</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" required="required" id="buy_type_un_u" name="buy_type_un" value="U" ${item.buy_type_un eq 'U' ? 'checked="checked"' : ''}>
										<label class="form-check-label" for="buy_type_un_u">중고</label>
									</div>
								</div>
							</div>
						</td>
						<th class="text-right r1s">감가시작일</th>
						<td>
							<div class="input-group width100px">
								<input type="text" class="form-control border-right-0 calDate r1b" id="reduce_st_dt" name="reduce_st_dt" dateFormat="yyyy-MM-dd" value="${item.reduce_st_dt}"  alt="감가시작일" onchange="fnCalcReduceMonth()">
							</div>
						</td>
						<th class="text-right">감가종료일</th>
						<td>
							<div class="input-group width100px">
								<input type="text" class="form-control border-right-0 calDate" id="reduce_ed_dt" name="reduce_ed_dt" dateFormat="yyyy-MM-dd" value="${item.reduce_ed_dt}" alt="감가 종료일" onchange="fnCalcReduceMonth()">
							</div>
						</td>
						<th class="text-right rs">관리센터</th>
						<td>
							<select class="form-control width90px rb" required="required" id="mng_org_code" name="mng_org_code" alt="관리센터">
								<option value="">- 선택 -</option>
								<c:forEach var="orgitem" items="${orgCenterList}">
									<option value="${orgitem.org_code}" ${orgitem.org_code eq item.mng_org_code ? 'selected="selected"' : ''}>${orgitem.org_name}</option>
								</c:forEach>
								<option value="5010">서비스지원</option>
							</select>
						</td>
					</tr>
					<tr>
						<th class="text-right">모델명</th>
						<td colspan="3">
							<div class="form-row inline-pd pr">
								<div class="col-auto">
									<div class="input-group">
										<input type="hidden" id="machine_seq" name="machine_seq" required="required" value="${item.machine_seq}">
										<input type="text" class="form-control border-right-0" value="${item.machine_name}" disabled="disabled">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goModelInfo();" ><i class="material-iconssearch"></i></button>
									</div>
								</div>
								
							</div>
						</td>
						<th class="text-right">번호판종류</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width130px">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="mreg_no_type_or" id="mreg_no_type_r" required="required" value="R" ${item.mreg_no_type_or eq 'R' ? 'checked="checked"' : ''}>
										<label class="form-check-label" for="mreg_no_type_r">임대</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="mreg_no_type_or" id="mreg_no_type_o" required="required" value="O" ${item.mreg_no_type_or eq 'O' ? 'checked="checked"' : ''}>
										<label class="form-check-label" for="mreg_no_type_o">자가</label>
									</div>
								</div>
							</div>
						</td>
						<th class="text-right">
							<span class="v-align-middle">실 운용비용</span>
							<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show()" onmouseout="javascript:hide()"></i></th>
							<!-- 마우스 오버시 레이어팝업 -->
							<div class="con-info" id="rental_operation" style="max-height: 500px; left: 50.5%; width: 245px; display: none; top:23.5%;">
								<ul class="">
									<ol style="color: #666;">&nbsp;실 운용비용 = 사용된 부품의 평균매입가 + 수리시간 * 무상기준공임단가만 포함한 수치</ol>
								</ul>
							</div>
						</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${real_oper_amt }" id="real_oper_amt" name="real_oper_amt" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">최대렌탈가능매출</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.max_rental_sale }" id="max_rental_sale" name="max_rental_sale" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">차대번호</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-8">
									<input type="text" class="form-control" readonly="readonly" value="${item.body_no}">
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra mr5" style="width: 100%;" onclick="javascript:goMachineDetail()">장비대장</button>
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
								</div>
							</div>
						</td>
						<th class="text-right">번호판번호</th>
						<td>
							<input type="text" class="form-control" value="${item.mreg_no}" id="mreg_no" name="mreg_no" maxlength="9">
						</td>
						<th class="text-right">감가월수</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" class="form-control text-right" readonly="readonly" id="reduce_month" name="reduce_month">
								</div>
								<div class="col width33px">개월</div>
								(${item.reduce_day}일)
							</div>
						</td>
						<th class="text-right">임대일수</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" class="form-control text-right" readonly="readonly" id="rental_days" name="rental_days" value="${item.rental_days}">
								</div>
								<div class="col width33px">일</div>
							</div>
						</td>
						<!-- 렌탈수익 -> 렌탈매출로 용어 변경 -->
						<th class="text-right">렌탈매출</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.rental_sale}" format="decimal" id="rental_sale" name="rental_sale">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">엔진모델</th>
						<td colspan="3">
							<input type="text" class="form-control" readonly="readonly" value="${item.engine_model_1}">
						</td>
						<th class="text-right">매입가격</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" format="num" id="buy_price" name="buy_price" readonly="readonly" value="${item.buy_price}">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">월감가액</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.reduce_price}" format="decimal" id="reduce_price" name="reduce_price">
								</div>
								<div class="col width16px">원</div>
								(일 감가 : <fmt:formatNumber type="number" maxFractionDigits="3" value="${item.reduce1_price}" />원)
							</div>
						</td>
						<th class="text-right">재렌탈수익</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.rerental_amt }" format="decimal" id="rerental_amt" name="rerental_amt">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">엔진번호</th>
						<td colspan="3">
							<input type="text" class="form-control" readonly="readonly" value="${item.engine_no_1}">
						</td>
						<th class="text-right">이자금액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.interest_amt}" format="decimal" name="interest_amt" id="interest_amt">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">감가총액</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.total_reduce_price}" format="decimal" id="total_reduce_price" name="total_reduce_price">
								</div>
								<div class="col width16px">원</div>
								(이전감가 : <fmt:formatNumber type="number" maxFractionDigits="3" value="${item.before_reduce_amt}" />원)
							</div>
						</td>
						<th class="text-right">재렌탈 현황</th>
						<td>
							<input type="text" class="form-control width90px" readonly="readonly" value="${item.rerental_cnt}">
						</td>
						<!-- 회의결과 반영(옥천센터, 일반센터 항목 삭제) -->
						<!-- <th class="text-right">옥천센터</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td> -->
					</tr>
					<tr>
						<th class="text-right">렌탈등록연도</th>
<%--						<th class="text-right">제조연식</th>--%>
						<td>
							<select class="form-control width60px" disabled>
								<option>${fn:substring(item.made_dt,0,4) }</option>
							</select>
						</td>
						<th class="text-right">제작연도</th>
						<td>
							<select class="form-control width70px" id="make_year" name="make_year">
								<c:forEach var="i" begin="1990" end="${inputParam.s_current_year}" step="1">
									<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
									<option value="${year_option}" <c:if test="${year_option eq item.make_year}">selected</c:if>>${year_option}년</option>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">장비가액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.machine_price }" format="decimal" id="machine_price" name="machine_price">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">최소판가</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.min_sale_price}" format="decimal" id="min_sale_price" name="min_sale_price">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
<%--						<th rowspan="2" class="text-right">장비상세</th>--%>
<%--						<td rowspan="2">--%>
<%--							<textarea class="form-control" id="remark" name="remark" maxlength="150" style="height: 60px;">${item.remark}</textarea>--%>
<%--						</td>--%>
						<th class="text-right">장비매각</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="checkbox" id="mch_sale_yn" name="mch_sale_yn" value="Y" ${item.mch_sale_yn eq 'Y' ? 'checked' : '' } onChange="javascript:fnMchSaleProc();">
								<span id="mch_sale_area"></span>
								<label class="form-check-input" for="mch_sale_yn" id="mch_sale_label">매각대상장비</label>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">가동시간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" class="form-control" readonly="readonly" value="${item.op_hour}">
								</div>
								<div class="col width22px">hr</div>
							</div>
						</td>
						<th class="text-right">최초등록일</th>
						<td>
							<div class="input-group width100px">
								<input type="text" class="form-control border-right-0 calDate" id="first_reg_dt" name="first_reg_dt" dateFormat="yyyy-MM-dd" value="${item.first_reg_dt}"  alt="최초등록일">
							</div>
						</td>
						<th class="text-right">수리비용</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.rental_repair_price }" format="decimal" id="rental_repair_price" name="rental_repair_price">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">운영년/월수</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width50px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.op_year }">
								</div>
								<div class="col width16px">년</div>
								<div class="col width16px text-center">/</div>
								<div class="col width50px">
									<%-- <input type="text" class="form-control text-right" readonly="readonly" value="${item.op_month }"> --%>
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.op_month_divide_year }">
								</div>
								<div class="col width33px">개월</div>
								(${item.op_day}일)
							</div>
						</td>
						<th rowspan="2" class="text-right">장비상세</th>
						<td rowspan="2">
							<textarea class="form-control" id="remark" name="remark" maxlength="150" style="height: 60px;">${item.remark}</textarea>
						</td>
					</tr>
					<tr>
						<th class="text-right">가동율1<br>(매출기준)</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" class="form-control" readonly="readonly" value="${item.util_rate}">
								</div>
								<div class="col width22px">%</div>
							</div>
						</td>
						<th class="text-right">가동율2<br>(임대일수 기준)</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" class="form-control" readonly="readonly" value="${item.util_rate_2}">
								</div>
								<div class="col width22px">%</div>
							</div>
						</td>
						<!-- 최종가액 -> 최종장비가액으로 변경(기획서 코맨트) -->
						<th class="text-right">최종 장비가액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" value="${item.final_machine_price }" id="final_machine_price" name="final_machine_price" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">GPS정보</th>
						<td colspan="5">
							<c:choose>
								<c:when test="${not empty item.sar }">
									<span class="underline" onclick="javascript:window.open('https://terra.smartassist.yanmar.com/machine-operation/map')">SA-R</span>
								</c:when>
								<c:otherwise>
									<input type="hidden" id="gps_seq" name="gps_seq" value="${item.gps_seq}" >
									<div class="form-row inline-pd widthfix">
										<div class="col width33px text-right">
											종류
										</div>
										<div class="col width100px">
											<select class="form-control" id="gps_type_cd" name="gps_type_cd" onclick="javascript:goGps();" >
												<option value="">- 선택 -</option>
												<c:forEach items="${codeMap['GPS_TYPE']}" var="codeitem">
													<option value="${codeitem.code_value}" ${item.gps_type_cd eq codeitem.code_value ? 'selected="selected"' : ''}>${codeitem.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col width60px text-right">
											개통번호
										</div>
										<div class="col width140px">
											<input type="text" class="form-control underline" readonly="readonly" id="gps_no" name="gps_no" value="${item.gps_no}" onclick="javascript:window.open('http://s1.u-vis.com')">
										</div>
									</div>
								</c:otherwise>
							</c:choose>
						</td>
					</tr>
					<tr>
						<th class="text-right">ROI</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" class="form-control"
										   id="roi_rate" name="roi_rate"
										   readonly="readonly" format="decimal" value="${item.roi_rate}">
								</div>
								<div class="col width22px">%</div>
							</div>
						</td>
						<th class="text-right">잔여비용</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right"
										   id="left_amt" name="left_amt"
										   readonly="readonly" format="decimal" value="${item.left_amt}">
								</div>
								<div class="col width22px">원</div>
							</div>
						</td>
						<th class="text-right">마케팅잔여비용</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right"
										   id="marketing_left_amt" name="marketing_left_amt"
										   readonly="readonly" format="decimal" value="${item.marketing_left_amt}">
								</div>
								<div class="col width22px">원</div>
							</div>
						</td>
						<th class="text-right">운임비</th>
						<td colspan="5">
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right"
										   id="transport_amt" name="transport_amt"
										   format="decimal" readonly="readonly" value="${item.transport_amt}" >
								</div>
								<div class="col width22px">원</div>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
<!-- /폼 테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<button type="button" id="_goRentalSaleInfoPopup" class="btn btn-info" onclick="javascript:goRentalSalePopup();">판매정보</button>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>