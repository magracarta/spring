<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 출하캘린더
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45

-- 5.14일 입고정보는 센터확정된것만 메이커-LC번호(카운트)만(신정애), LC의 입고예정일 기준으로조회 카운트는 그 엘씨의 센터 
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		function goSearch() {
			var param = {
				"s_current_mon" : $M.getValue("s_year")+$M.getValue("s_mon"),
				"s_center_org_code" : $M.getValue("s_center_org_code")
			};	
			$M.goNextPage(this_page, $M.toGetParam(param), {method:"GET"});
		}
		
		function goMachineDoc(docNo, type, dt) {
			var popupOption = "";
			if (type == "LC") {
				var param = {
					machine_lc_no : docNo	
				};
				$M.goNextPage('/serv/serv0201p02', $M.toGetParam(param), {popupStatus : popupOption});
			} else if (type == "SALE") {
				var url = '/sale/sale0101p03';
				var param = {
					machine_doc_no : docNo	
				}
				$M.goNextPage(url, $M.toGetParam(param), {popupStatus : popupOption});
			} else if (type == "STOCK") {	
				var url = '/sale/sale0101p09';
				var param = {
					machine_doc_no : docNo	
				}		
				$M.goNextPage(url, $M.toGetParam(param), {popupStatus : popupOption});
			} else if (type == "RS") {
				goReservation(dt);
			}
		}	
		
		function goReservation(dt) {
			// 관리권한없을경우
			<c:if test="${page.fnc.F02033_004 ne 'Y'}">
				alert("관리 권한이 없습니다.");
				return false;
			</c:if>
			var selectedOrgCode = $M.getValue("s_center_org_code");
			
			if (selectedOrgCode == "") {
				alert("센터를 선택해주세요.");
				return false;
			}

			if ("${page.fnc.F02033_001}" == "Y" && "${SecureUser.org_code}" != selectedOrgCode) {
				alert("선택하신 센터는 소속 센터가 아닙니다.");
				return false;
			}
			
			var param = {
				s_out_org_code : selectedOrgCode,
				s_receive_plan_dt : dt,
				parent_js_name : "fnRefresh"
			}
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=480, left=0, top=0";
   			$M.goNextPage('/sale/sale0101p16', $M.toGetParam(param), {popupStatus: poppupOption});
		}
		
		function fnRefresh() {
			location.reload();
		}
	</script>
	
	<style type="text/css">
		.date {
			cursor: pointer;
		}
		li {
			white-space: nowrap;
		    overflow: hidden;
		    text-overflow: ellipsis;
		    cursor: pointer;
		}
		.am, .pm > li {
			/* text-align-last: justify; */
		}
		.datail-list2 > .pm {
			/* 오후만 있을때 공간 */
			/* margin-top: 65%; */
		}
		.datail-list2 > .am + .pm{
			/* margin-top: 1%; */
		}
		.datail-list2 > .lc + .am{
			/* margin-top: 1%; */
		}
		.datail-list2 ul ~ ul {
			margin-top: 1%;
		}
		.calendar-table .datail-list2 {
			font-size: 12px;
			letter-spacing: -1px;
		}
		.datail-list2 .lc {
		    background: #fffabf;
		    color: #000;
		    padding: 5px;
		    border-radius: 5px;
		}
		.bul-lc {padding-right: 5px;position: relative; padding-left: 15px;}
		.bul-pm {padding-right: 5px;}
		.bul-lc:before {content: ""; display: inline-block; position: absolute; left: 0; top: 1px; width: 10px; height: 10px; border-radius: 3px; background: #fffabf;}
		.bul-am:before, .bul-pm:before, .bul-lc:before {border: 1px solid #eee;}
		.status5, .status6 {color : darkgray;}
	</style>
</head>
<body>
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per">
<!-- contents 전체 영역 -->
	<!-- 메인 타이틀 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /메인 타이틀 -->
	<div class="content-wrap" style="padding-top: 0">
		<div class="">
			<div class="">		
                   	<div class="search-wrap mt10">
                        <table class="table">
                            <colgroup>
                                <col width="60px">
                                <col width="150px">
                                <col width="30px">
                                <col width="80px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                                <tr>							
                                    <th>조회년월</th>	
                                    <td>
                                        <div class="form-row inline-pd widthfix">
                                            <div class="col width80px">
                                                <select class="form-control" id="s_year" name="s_year" alt="조회년">
					                                <c:forEach var="i" begin="1" end="22" varStatus="status">
					                                	<option value="${inputParam.s_current_year-i+1}" <c:if test="${(inputParam.s_current_year-i+1)==s_start_year}">selected</c:if>>${inputParam.s_current_year-i+1}년</option>
					                                </c:forEach>
					                            </select>
                                            </div>
                                            <div class="col width60px">
                                                <select class="form-control" id="s_mon" name="s_mon" alt="조회월">
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_start_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
                                                </select>
                                            </div>
                                        </div>
                                    </td>
                                    <th>센터</th>
                                    <td>
										<select class="form-control width100px" id="s_center_org_code" name="s_center_org_code" ${page.fnc.F02033_004 eq 'Y' and page.fnc.F02033_001 eq 'Y' ? '' : 'readonly'}> <!-- 출하센터는 자신의 센터만 조회가능 -->
                                        	<c:forEach var="item" items="${orgList}">
												<option value="${item.org_code}" <c:if test="${item.org_code==inputParam.s_center_org_code}">selected</c:if>>${item.org_name}</option>
											</c:forEach>
										</select>
                                    </td>	
                                    <td class="">
                                        <button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch()">조회</button>
                                        <div style="float: right;margin-top: 3px;">
                                        	<span class="text-warning" style="margin-right: 10px;">${admin_yn eq 'Y' ? '※ &lt;센터 선택 후 달력날짜&gt; 클릭 시 출고불가설정가능' : '※ 본인 출하의뢰서만 조회 가능'}</span>
                                        	<span class="bul-lc">입고예정</span>
	                                        <span class="bul-am">오전</span>
	                                        <span class="bul-pm">오후</span>
											<span class="bul-cf">관리확인</span>
                                        </div>
                                    </td>
                                </tr>							
                            </tbody>
                        </table>
                    </div>
                    <table class="calendar-table mt10">
                    	<colgroup>
                            <col width="45px">
                            <%-- <col width=""> --%>
                            <col width="200px">
                            <col width="200px">
                            <col width="200px">
                            <col width="200px">
                            <col width="200px">
                            <%-- <col width=""> --%>
                        </colgroup>
                        <thead>
                            <tr>
                                <th class="complete-bg">구분</th>
                                <!-- <th class="sunday-bg">일</th> -->
                                <th>월</th>
                                <th>화</th>
                                <th>수</th>
                                <th>목</th>
                                <th>금</th>
                                <!-- <th class="satuday-bg">토</th> -->
                            </tr>
                        </thead>
                        <tbody>
                        	<c:forEach var="rows" items="${list}">
	                            <tr>
	                            	<c:forEach var="days" items="${rows}" varStatus="status">
	                            		<c:if test="${status.index eq 0}">
			                                <td class="complete-bg week-title">
			                                    <div class="week-item">
			                                        	${days.week_cnt}<br>주차
			                                    </div>
			                                </td>
		                                </c:if>
		                                <c:if test="${days.week ne '1' and days.week ne '7'}">
			                                <td>
			                                    <div class="date-item">
			                                        <div class="date<c:if test="${days.same_mon_yn eq 'N'}"> prev</c:if>" onclick="javascript:goReservation('${days.work_dt}')">${days.day}</div>
			                                    </div>
			                                    <c:if test="${not empty detail[days.work_dt]}">
			                                    	<div class="datail-list2" style="padding-top: 0">
				                                    	<c:forEach var="item" items="${detail[days.work_dt]}">
			                                    			<c:forEach var="type" items="${item.key}">
			                                    				<c:if test="${type eq '0'}">
				                                    				<ul class="lc">
							                                        	<c:forEach var="li" items="${detail[days.work_dt][type]}" varStatus="index">
							                                            	<li class="status${li.machine_doc_status_cd}" onclick="javascript:goMachineDoc('${li.machine_doc_no}', '${li.machine_doc_type_cd}', '${li.receive_plan_dt}')">${index.count}. (${fn:substring(li.out_org_name,0,2)}) ${li.cust_full_name } / ${fn:substring(li.machine_doc_no, 2, 12)} (${li.container_cnt })</li>
							                                            </c:forEach>
							                                        </ul>
				                                    			</c:if>
																<!-- '관리확인' 추가 -->
																<c:if test="${type eq '3'}">
																	<ul class="cf">
																		<c:forEach var="li" items="${detail[days.work_dt][type]}" varStatus="index">
																			<li class="status${li.machine_doc_status_cd}" onclick="javascript:goMachineDoc('${li.machine_doc_no}', '${li.machine_doc_type_cd}', '${li.receive_plan_dt}')">${index.count}. (관리확인 | ${fn:substring(li.out_org_name,0,2)}) ${li.cust_name } ${li.machine_name } ${li.addr } ${li.receive_plan_ti_view }</li>
																		</c:forEach>
																	</ul>
																</c:if>
				                                    			<c:if test="${type ne '0' && type ne '3'}">
				                                    				<ul class="${type eq '1' ? 'am' : 'pm'}">
							                                        	<c:forEach var="li" items="${detail[days.work_dt][type]}" varStatus="index">
							                                            	<li class="status${li.machine_doc_status_cd}" onclick="javascript:goMachineDoc('${li.machine_doc_no}', '${li.machine_doc_type_cd}', '${li.receive_plan_dt}')">${index.count}. (${fn:substring(li.out_org_name,0,2)}) ${li.cust_name } ${li.machine_name } ${li.addr } ${li.receive_plan_ti_view }</li>
							                                            </c:forEach>
							                                        </ul>
				                                    			</c:if>
			                                    			</c:forEach>
			                                    		</c:forEach>
					                                </div>
		                                    	</c:if>
			                                </td>
		                                </c:if>
	                                </c:forEach>
	                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>					
				</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>