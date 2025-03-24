<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > 렌탈장비 신규등록 > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	$(document).ready(function() {
		
	});
	
	function fnList() {
		$M.goNextPage("/rent/rent0201");
	}
	
	function goSave() {
		
		var madeDtTemp = $M.getValue("made_dt_temp");
		$M.setValue("made_dt", madeDtTemp+"0101");
		
		var frm = $M.toValueForm(document.main_form);
		
		if($M.validation(frm, {field:["made_dt_temp", "mreg_no_type_or", "buy_type_un_u", "reduce_yn"]}) == false) {
			return false;
		}

		if (!$M.validation(document.main_form)) {
			return false;
		}
		
		if ($M.getValue("reduce_yn") == "Y") {
			if($M.validation(frm, {field:["reduce_st_dt"]}) == false) {
				return;
			}
			if($M.checkRangeByFieldName('reduce_st_dt', 'reduce_ed_dt', true) == false) {
				return;
			};				
		} 
		
		if (confirm("렌탈장비 등록 시, 장비 소유자가 YK렌탈장비로 변경됩니다.\n계속하시겠습니까?") == false) {
			return false;
		}
		
		$M.goNextPageAjax(this_page+"/save", frm, {method: 'post'},
                function (result) {
					if (result.success) {
                     	fnList();
					}
                }
           );
		
	}
	
	function fnSetInformation(data) {
		console.log(data);
		var param = {
			machine_seq : data.machine_seq,
			body_no : data.body_no,
			machine_name : data.machine_name,
			maker_name : data.maker_name,
			engine_model_1 : data.engine_model_1,
			engine_no_1 : data.engine_no_1
		}
		$M.setValue(param);
	}
	
	function fnCalcReduceMonth() {
    	if ($M.getValue("reduce_st_dt") == "") {
    		$M.setValue("reduce_month", 0);
    	} else {
    		if ($M.getValue("reduce_ed_dt") == "") {
    			// 감가종료일이 없으면 오늘날짜까지 감가 계산
    			var cnt = $M.getDiff("${inputParam.s_current_dt}", $M.getValue("reduce_st_dt"));
    			var reduceMonth = Math.ceil((cnt/30)*10)/10;
    			if (reduceMonth < 0) {
    				reduceMonth = 0;
    			}
    			$M.setValue("reduce_month", reduceMonth);
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

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="made_dt" name="made_dt" alt="제조연식">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼 테이블 -->			
					<table class="table-border">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">관리번호</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control" readonly>
										</div>
									</div>
								</td>
								<th class="text-right rs">매입일자</th>
								<td>
									<div class="input-group width100px">
										<input type="text" class="form-control rb border-right-0 calDate" required="required" id="buy_dt" name="buy_dt" dateFormat="yyyy-MM-dd" value="${item.buy_dt}" alt="매입일자">
									</div>
								</td>
								<th class="text-right">감가여부</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width130px">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" required="required" id="reduce_y" name="reduce_yn" checked="checked" value="Y" onclick="javascript:fnSetReduceYn()">
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
								<td>
									<input type="text" class="form-control" readonly="readonly" name="maker_name">
								</td>
								<th class="text-right">매입종류</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width130px">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" required="required" id="buy_type_un_u" name="buy_type_un" value="U" checked="checked">
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
								<td>
									<input type="text" class="form-control" disabled="disabled" name="machine_name">
								</td>
								<th class="text-right">번호판종류</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width130px">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="mreg_no_type_or" id="mreg_no_type_r" required="required" value="R" checked="checked">
												<label class="form-check-label" for="mreg_no_type_r">임대</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="mreg_no_type_or" id="mreg_no_type_o" required="required" value="O">
												<label class="form-check-label" for="mreg_no_type_o">자가</label>
											</div>
										</div>									
									</div>	
								</td>
								<th class="text-right">감가종료일</th>
								<td>
									<div class="input-group width100px">
										<input type="text" class="form-control border-right-0 calDate" id="reduce_ed_dt" name="reduce_ed_dt" dateFormat="yyyy-MM-dd" value="${item.reduce_ed_dt}" alt="감가 종료일" onchange="fnCalcReduceMonth()">
									</div>
								</td>
								<th class="text-right"><!-- 최대렌탈가능매출 --></th>
								<td>
									<!-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div> -->
								</td>
							</tr>
							<tr>
								<th class="text-right rs">차대번호</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0 rb" readonly="readonly" required="required" id="body_no" name="body_no" alt="차대번호">
										<input type="hidden" id="machine_seq" name="machine_seq">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchDeviceHisPanel('fnSetInformation');" ><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th class="text-right">번호판번호</th>
								<td>
									<input type="text" class="form-control" value="${item.mreg_no}" id="mreg_no" name="mreg_no" maxlength="9" alt="번호판번호">
								</td>
								<th class="text-right">감가월수</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" class="form-control text-right" readonly="readonly" id="reduce_month" name="reduce_month">
										</div>
										<div class="col width33px">개월</div>
									</div>
								</td>
								<th class="text-right"><!-- 렌탈수익 --></th>
								<td>
									<!-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div> -->
								</td>
							</tr>
							<tr>
								<th class="text-right">엔진모델</th>
								<td>
									<input type="text" class="form-control" readonly="readonly" id="engine_model_1" name="engine_model_1">
								</td>
								<th class="text-right rs">매입가격</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right rb" format="num" id="buy_price" name="buy_price" required="required" alt="매입가격">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right"><!-- 월감가액 --></th>
								<td>
									<!-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div> -->
								</td>
								<th class="text-right"><!-- 재렌탈수익 --></th>
								<td>
									<!-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div> -->
								</td>
							</tr>
							<tr>
								<th class="text-right">엔진번호</th>
								<td>
									<input type="text" class="form-control" readonly="readonly" id="engine_no_1" name="engine_no_1">
								</td>
								<th class="text-right"><!-- 이자금액 --></th>
								<td>
									<%-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" value="${item.interest_amt}" format="decimal" name="interest_amt" id="interest_amt">
										</div>
										<div class="col width16px">원</div>
									</div> --%>
								</td>
								<th class="text-right"><!-- 감가총액 --></th>
								<td>
									<!-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right">
										</div>
										<div class="col width16px">원</div>
									</div> -->
								</td>
								<th class="text-right"><!-- 옥천센터 --></th>
								<td>
									<!-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right">
										</div>
										<div class="col width16px">원</div>
									</div> -->
								</td>
							</tr>
							<tr>
								<th class="text-right rs">렌탈등록연도</th>
								<td>
									<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
										<jsp:param name="sort_type" value="d"/>
										<jsp:param name="year_name" value="made_dt_temp"/>
									</jsp:include>
								</td>
								<th class="text-right">제작연도</th>
								<td>
									<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
										<jsp:param name="sort_type" value="d"/>
										<jsp:param name="year_name" value="make_year"/>
									</jsp:include>
								</td>
								<th class="text-right"><!-- 총 수리비용 합계 --></th>
								<td>
									<!-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div> -->
								</td>
								<th class="text-right"><!-- 최소판가 --></th>
								<td>
									<!-- <div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div> -->
								</td>
								<!-- <th class="text-right">일반센터</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div>
								</td> -->
							</tr>
							<!-- <tr>
								<th class="text-right">가동시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
										</div>
										<div class="col width22px">hr</div>
									</div>
								</td>
								<th class="text-right">졍산완료수리비용</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">운영년/월수</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width50px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">년</div>
										<div class="col width16px text-center">/</div>
										<div class="col width40px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width33px">개월</div>
									</div>
								</td>
								<th class="text-right">재 렌탈조건</th>
								<td>
									<input type="text" class="form-control" readonly>
								</td>
							</tr>
							<tr>
								<th class="text-right">가동율</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" class="form-control" readonly>
										</div>
										<div class="col width22px">%</div>
									</div>
								</td>
								<th class="text-right">최종가액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly>
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">GPS정보</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width33px text-right">
											종류
										</div>
										<div class="col width100px">
											<select class="form-control">
												<option>선택</option>
											</select>
										</div>
										<div class="col width60px text-right">
											개통번호
										</div>
										<div class="col width140px">
											<input type="text" class="form-control" readonly>
										</div>
									</div>
								</td>
							</tr>	 -->								
						</tbody>
					</table>			
<!-- /폼 테이블 -->	
					<div class="btn-group mt10">
						<div class="right">
							<button type="button" class="btn btn-info" onclick="javascript:goSave();" >저장</button>
							<button type="button" class="btn btn-info" onclick="javascript:fnList();" >목록</button>
						</div>
					</div>
				</div>											
			</div>	
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
		</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>